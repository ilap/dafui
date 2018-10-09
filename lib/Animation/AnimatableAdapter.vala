/**
 * Copyright (c) 2012 Pal Dorogi <pal.dorogi@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 **/

using Gtk;

namespace Daf.UI.Animation {

    /**
     * This helper calls is about to adapt the opacity for a widget.
     */
    public class AnimatableAdapter : Container {

        // Animatable properties...

        /**
         */
        private double _opacity = 1f;
        public double opacity {
            get { return _opacity; }
            set {
                _opacity = value < 0f ? 0f : value > 1f ? 1 : value;
            }
        }


        // Not implemented yet. public double background_opacity { set; get; default = 0;}

        public int offset_x { set; get; default = 0;}
        public int offset_y { set; get; default = 0;}

        // Fields...
        private Gdk.Window? off_win = null;
        public Widget? child { get; private set; default = null; }

        construct {
            // Set background transparent.
            override_background_color (StateFlags.NORMAL, { 0f, 0f, 0f, 0f} );
        }

        public AnimatableAdapter (Widget child) {

            set_has_window (true);

            this.child = child;
            this.child.set_parent_window (off_win);
            this.child.set_parent (this);

            this.notify.connect ( () => {
                if (child != null && child.visible) {
                   child.queue_draw ();
                }
            });
        }

        public unowned Gdk.Window on_pick_embedded_child (double x, double y) {
           return this.off_win;
        }

        public override bool draw (Cairo.Context cr) {

            if (Gtk.cairo_should_draw_window (cr, get_window ()) && child.visible) {

                var surface = Gdk.offscreen_window_get_surface (off_win);
                cr.translate (offset_x, offset_y);
                cr.set_source_surface (surface, 0, 0);
                if (opacity != 1f) {
                    cr.paint_with_alpha (opacity);
                } else {
                    cr.paint ();
                }
            } else if (Gtk.cairo_should_draw_window (cr, off_win)) {
                propagate_draw (child, cr);
            }

            Allocation alloc;

            if (child != null) {
                child.get_allocation (out alloc);
                print_alloc (child, "Child", alloc);
            }
            return true;
        }

        public override void add (Widget widget) {
            error ("This container widget cannot have more than one child.");
        }

        public override void remove (Widget widget) {
            // Override to prevent remove the widget.
            return;
        }

        public override bool damage_event (Gdk.EventExpose expose) {
            Gdk.Window window;

            if ((window = get_window ()) != null) {
                window.invalidate_rect (null, false);
            }
            return true;
        }

        public override void forall_internal (bool include_internal, Gtk.Callback callback) {
            if (child != null) {
                callback (child);
            }
        }

        public override void realize () {

            Gdk.WindowAttributesType attr_mask = Gdk.WindowAttributesType.X |
                                                Gdk.WindowAttributesType.Y |
                                                Gdk.WindowAttributesType.VISUAL;

            var alloc = Allocation ();
            get_allocation (out alloc);

            var border_width =  (int) get_border_width ();

            set_realized (true);

            var attr = Gdk.WindowAttr ();

            attr.x = alloc.x + border_width;
            attr.y = alloc.y + border_width;
            attr.width = alloc.width + 2 * border_width;
            attr.width = alloc.width + 2 * border_width;
            attr.event_mask = get_events () | Gdk.EventMask.ALL_EVENTS_MASK;

            attr.visual = get_visual ();
            attr.wclass = Gdk.WindowWindowClass.INPUT_OUTPUT;

            attr.window_type = Gdk.WindowType.CHILD;

            var window = new Gdk.Window (get_parent_window (), attr, attr_mask);
            set_window (window);
            window.set_user_data (this);
            window.pick_embedded_child.connect (on_pick_embedded_child);

            attr.window_type = Gdk.WindowType.OFFSCREEN;

            if (child.visible) {
                    child.get_allocation (out alloc);
                    attr.width = alloc.width;
                    attr.height = alloc.height;
            }

            off_win = new Gdk.Window (get_root_window (), attr, attr_mask);
            off_win.set_user_data (this);

            if (child != null) {
                child.set_parent_window (off_win);
            }

            Gdk.offscreen_window_set_embedder (off_win, window);

            // This needs for the proper cursor
            off_win.to_embedder.connect (on_embedder_event);
            off_win.from_embedder.connect (on_embedder_event);

            off_win.show ();
        }

        public void on_embedder_event (double x, double y, out double x1, out double y1) {
            x1 = x;
            y1 = y;
        }

        public override void unrealize () {

            off_win.set_user_data (null);
            off_win.destroy ();
            off_win = null;

            if (child != null) {
                child.unparent ();;
                child = null;
            }

            base.unrealize ();
        }

        public override void size_allocate (Allocation alloc) {

            print_alloc (this, "AnimatableAdapter size_allocate1", alloc);
            set_allocation (alloc);

            var border_width = (int) get_border_width ();

            var x = alloc.x + border_width;
            var y = alloc.y + border_width;

            var w = int.max (1, alloc.width - 2 * border_width);
            var h = int.max (1, alloc.height - 2 * border_width);

           print_alloc (this, "AnimatableAdapter size_allocate 2", alloc);


            if (get_realized ()) {
                get_window ().move_resize (x, y, w, h);
                off_win.move_resize (x, y, w, h);
            }

            alloc.x = alloc.y = 0;
            alloc.width = w;
            alloc.height = h;

            // Child allocation.
            print_alloc (child, "Alloc....", alloc);
            child.size_allocate (alloc);
        }

        public void print_alloc (Widget w, string msg, Allocation a) {
            debug ("Allocation for Widget: %s (%s): x: %d, y: %d, w: %d, h: %d", w.name, msg, a.x, a.y, a.width, a.height);
        }
    }
}