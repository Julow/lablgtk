(* $Id$ *)

open Misc
open Gtk
open GUtil
open GObj

class separator_wrapper w = widget_wrapper (Separator.coerce w)

class separator dir ?:packing =
  object (self)
    inherit separator_wrapper (Separator.create dir)
    initializer pack_return :packing (self :> separator_wrapper)
  end

class statusbar_context obj ctx = object (self)
  val obj : Statusbar.t obj = obj
  val context : Statusbar.context = ctx
  method context = context
  method push text = Statusbar.push obj context :text
  method pop () = Statusbar.pop obj context
  method remove = Statusbar.remove obj context
  method flash text ?:delay [< 1000 >] =
    let msg = self#push text in
    Timeout.add delay callback:(fun () -> self#remove msg; false);
    ()
end

class statusbar_wrapper obj = object
  inherit GCont.container_wrapper (obj : Statusbar.t obj)
  method new_context :name =
    new statusbar_context obj (Statusbar.get_context obj name)
end

class statusbar ?:border_width ?:width ?:height ?:packing =
  let w = Statusbar.create () in
  let () = Container.setter w ?:border_width ?:width ?:height cont:null_cont in
  object (self)
    inherit statusbar_wrapper w
    initializer pack_return :packing (self :> statusbar_wrapper)
  end

class drawing_area_wrapper obj = object
  inherit widget_wrapper (obj : DrawingArea.t obj)
  method set_size = DrawingArea.size obj
end

class drawing_area  ?:width [< 0 >] ?:height [< 0 >] ?:packing =
  let w = DrawingArea.create () in
  let () =
    if width <> 0 || height <> 0 then DrawingArea.size w :width :height in
  object (self)
    inherit drawing_area_wrapper w
    initializer pack_return :packing (self :> drawing_area_wrapper)
  end

class misc obj = object
  inherit widget obj
  method set_alignment = Misc.set_alignment obj
  method set_padding = Misc.set_padding obj
end

class label_skel obj = object
  inherit misc obj
  method set_text = Label.set_text obj
  method set_justify = Label.set_justify obj
  method text = Label.get_text obj
end

class label_wrapper obj = object
  inherit label_skel (Label.coerce obj)
  method connect = new widget_signals ?obj
end

class label ?:text [< "" >] ?:justify ?:line_wrap ?:pattern
    ?:xalign ?:yalign ?:xpad ?:ypad ?:packing =
  let w = Label.create text in
  let () =
    Label.setter w cont:null_cont ?:justify ?:line_wrap ?:pattern;
    Misc.setter w cont:null_cont ?:xalign ?:yalign ?:xpad ?:ypad
  in
  object (self)
    inherit label_wrapper w
    initializer pack_return :packing (self :> label_wrapper)
  end

class tips_query_signals obj ?:after = object
  inherit widget_signals obj ?:after
  method widget_entered :callback = 
    Signal.connect sig:TipsQuery.Signals.widget_entered obj ?:after
      callback:(function None -> callback None
	| Some w -> callback (Some (new widget_wrapper w)))
  method widget_selected :callback = 
    Signal.connect sig:TipsQuery.Signals.widget_selected obj ?:after
      callback:(function None -> callback None
	| Some w -> callback (Some (new widget_wrapper w)))
end

class tips_query_wrapper obj = object
  inherit label_skel (obj : TipsQuery.t obj)
  method start () = TipsQuery.start obj
  method stop () = TipsQuery.stop obj
  method set_caller : 'a . (#is_widget as 'a) -> unit =
    fun w -> TipsQuery.set_caller obj (w #as_widget)
  method set_labels = TipsQuery.set_labels obj
  method connect = new tips_query_signals ?obj
end

class tips_query ?:caller ?:emit_always ?:label_inactive ?:label_no_tip
    ?:packing =
  let w = TipsQuery.create () in
  let () =
    TipsQuery.setter w cont:null_cont ?:caller ?:emit_always
      ?:label_inactive ?:label_no_tip
  in
  object (self)
    inherit tips_query_wrapper w
    initializer pack_return :packing (self :> tips_query_wrapper)
  end
