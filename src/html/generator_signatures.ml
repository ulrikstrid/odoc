module Html = Tyxml.Html
module Lang = Model.Lang



type rendered_item = Html_types.div_content Html.elt list
(* [rendered_item] should really be [dt_content], but that is bugged in TyXML
   until https://github.com/ocsigen/tyxml/pull/193 is released. *)

type ('inner, 'outer) text =
  [> `PCDATA | `Span | `A of ([> `PCDATA] as 'inner)] as 'outer

type ('item_kind, 'item) tagged_item = [
  | `Leaf_item of 'item_kind * 'item
  | `Nested_article of 'item
  | `Comment of Model.Comment.docs_or_stop
]

type section = {
  anchor : string;
  text : Model.Comment.link_content;
  children : section list
}

type toc = section list



(** HTML generation syntax customization module. See {!To_re_html_tree} and
    {!To_ml_html_tree}. *)
module type SYNTAX =
sig
  module Obj :
  sig
    val close_tag_closed : string
    val close_tag_extendable : string
    val field_separator : string
    val open_tag_closed : string
    val open_tag_extendable : string
  end

  module Type :
  sig
    val annotation_separator : string

    val handle_constructor_params :
      ('inner, 'outer) text Html.elt list ->
      ('inner, 'outer) text Html.elt list ->
        ('inner, 'outer) text Html.elt list

    val handle_substitution_params :
      ('inner, 'outer) text Html.elt list ->
      ('inner, 'outer) text Html.elt list ->
        ('inner, 'outer) text Html.elt list

    val handle_format_params : string -> string
    val type_def_semicolon : bool
    val private_keyword : string
    val parenthesize_constructor : bool

    module Variant :
    sig
      val parenthesize_params : bool
    end

    module Tuple :
    sig
      val element_separator : string
      val always_parenthesize : bool
    end

    module Record :
    sig
      val field_separator : string
    end

    val var_prefix : string

    val any : string

    val arrow : [> Html_types.span | Html_types.pcdata ] Html.elt

    module Exception :
    sig
      val semicolon : bool
    end

    module GADT :
    sig
      val arrow : [> Html_types.span | Html_types.pcdata ] Html.elt
    end

    module External :
    sig
      val semicolon : bool
      val handle_primitives :
        string list ->
          [< Html_types.code_content_fun > `A `PCDATA `Span] Tyxml_html.elt list
    end
  end

  module Mod :
  sig
    val open_tag : string
    val close_tag : string
    val close_tag_semicolon : bool
    val include_semicolon : bool
    val functor_keyword : bool
  end

  module Class :
  sig
    val open_tag : string
    val close_tag : string
  end

  module Value :
  sig
    val variable_keyword : string
    val semicolon : bool
  end
end



module type GENERATOR =
sig
  module Top_level_markup :
  sig
    val lay_out :
      item_to_id:('item -> string option) ->
      item_to_spec:('item -> string option) ->
      render_leaf_item:('item -> rendered_item * Model.Comment.docs) ->
      render_nested_article:
        ('item -> rendered_item * Model.Comment.docs * (Html_tree.t list)) ->
      (_, 'item) tagged_item list ->
        rendered_item * toc * (Html_tree.t list)

    val render_toc :
      toc -> [> Html_types.flow5_without_header_footer] Html.elt list
  end

  module Page : sig
    val compilation_unit :
      ?theme_uri:Html_tree.uri -> Lang.Compilation_unit.t -> Html_tree.t
    val page : ?theme_uri:Html_tree.uri -> Lang.Page.t -> Html_tree.t
  end
end