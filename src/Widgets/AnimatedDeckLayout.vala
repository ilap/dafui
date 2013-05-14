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

using Daf.UI.Animation;
using Daf.UI.Widgets;

namespace Daf.UI.Widgets {

    /**
     * AnimatedDeckLayout which demonstrates the fade-in-out between
     * Containers/Widgets.
     */
    public class AnimatedDeckLayout : AbstractDeckLayout {

        public TimeLine timeline { public get; construct set; }
        //public bool use_widget_request { get; set; default = false; }

        private Gtk.Window? toplevel = null;
        private bool resizable = false;

        private PropertyAnimator? fade_in = null;
        private PropertyAnimator? fade_out = null;

        private PropertyAnimator? grow = null;

        private ICard? from_card = null;

        public AnimatedDeckLayout () {
            this.with_timeline (new TimeLine.full (AnimationMode.EASE_IN_OUT_QUAD, 450));
            //timeline.completed.connect (on_animation_completed);
        }

        public AnimatedDeckLayout.with_timeline (TimeLine timeline) {
            this.timeline = timeline;
            this.timeline.completed.connect (on_animation_completed);
        }

        public override void add (Widget widget) {
            base.add (widget);
        }

        public void on_animation_completed (Object object) {
            //sensitive = true;
            if (from_card != null) {

                // Hide the old card.
                from_card.widget.set_child_visible (false);
                from_card.visible = false;

                // Revert the changes;
                if (from_card.widget is AnimatableAdapter) {
                    (from_card.widget as AnimatableAdapter).opacity = (from_card as AnimatedCard).opacity;
                }

                from_card = null;

                if (active_card !=null) {
                    // we should reset it to -1 anyway.
                    active_card.widget.width_request = (active_card as AnimatedCard).width_request;
                    active_card.widget.height_request = (active_card as AnimatedCard).height_request;
                }

                if (toplevel != null) {
                    toplevel.resizable = resizable;
                }
            }
        }

        protected override ICard create_card (Widget widget) {
            widget.set_parent (this);
            AnimatedCard card = new AnimatedCard (widget);

            card.width_request = widget.width_request;
            card.height_request = widget.height_request;

            return card;
        }

        protected override void compute_width (ICard card, out int minimum, out int natural) {
            card.widget.get_preferred_width (out minimum, out natural);
        }

        protected override void compute_height (ICard card, out int minimum, out int natural) {
            card.widget.get_preferred_height (out minimum, out natural);
        }

        private void do_quiet (ICard to_card) {
            active_card.widget.set_child_visible (false);
            active_card.visible = false;

            active_card = to_card;
            active_card.widget.set_child_visible (true);
            active_card.visible = true;
        }

        protected override bool do_switch (ICard? to_card, bool quiet = true) {
            if (to_card == null || active_card == null || active_card.widget == null) {
                return false;
            }

            save_state (active_card);

            if (quiet) {
                // We should use a base.do_switch (to_card, true) solution whihc
                // needs the base method implemented as a virtual method.
                do_quiet (to_card);
            } else {

                int w;
                int h;

                if (get_state (to_card, out w, out h)) {

                    fade_in = create_resizable_animation (to_card, 0f, (to_card as AnimatedCard).opacity, w, h);

                    fade_in.set_keyframe (0.75, "opacity", 0f);
                    fade_in.set_keyframe (0.75, "width-request", w);
                    fade_in.set_keyframe (0.75, "height-request", h);

                } else {

                    // Saved state is not valid...
                    fade_in = create_animation (to_card, 0f, (to_card as AnimatedCard).opacity);
                }

                fade_out = create_animation (active_card, (active_card as AnimatedCard).opacity, 0f);

                if (fade_in != null) {// && fade_out != null) {
                    //sensitive = false;

                    from_card = active_card;
                    active_card = to_card;

                    if (!timeline.playing) {

                        // Set the allocated width and height.
                        var tmp_card = to_card as AnimatedCard;
                        if (to_card.widget is AnimatableAdapter) {
                            var anim_card = to_card.widget as AnimatableAdapter;

                            //anim_card.x = -anim_card.width_request;
                            anim_card.offset_y = -anim_card.height_request;
                        }

                        to_card.widget.width_request = get_allocated_width ();
                        to_card.widget.height_request = get_allocated_height ();

                        to_card.visible = true;
                        to_card.widget.set_child_visible (true);

                        if (toplevel == null) {
                            var tl = get_toplevel ();
                            if (tl is Gtk.Window) {
                                toplevel = tl as Gtk.Window;
                                resizable = toplevel.resizable;
                            }
                        } else {
                            toplevel.resizable = false;
                        }

                        timeline.start ();
                    }
                } else {
                    do_quiet (to_card);
                }
            }

            return true;
        }

        private PropertyAnimator? create_resizable_animation (ICard card, double from, double to, int width, int height) {
            PropertyAnimator? result = null;
            var widget = card.widget;
            grow = null;

            if (widget is AnimatableAdapter) {

                var tmp_widget = widget as AnimatableAdapter;
                tmp_widget.opacity = from;
                result = PropertyAnimator.animate_with_timeline (tmp_widget, timeline,
                "offset-x", 0,
                "offset-y", 0,
                "width-request", width,
                "height-request", height,
                "opacity", to);

            } else {
                result = PropertyAnimator.animate_with_timeline (widget, timeline,
                "offset-x", 0,
                "offset-y", 0,
                "width-request", width,
                "height-request", height );
            }
            return result;
        }

        private PropertyAnimator? create_animation (ICard card, double from, double to) {
            PropertyAnimator? result = null;
            var widget = card.widget;

            if (widget is AnimatableAdapter) {
                (widget as AnimatableAdapter).opacity = from;
                result = PropertyAnimator.animate_with_timeline (widget, timeline, "opacity", to,
                "offset-x", 0,
                "offset-y", -40);
            }
            return result;
        }

        protected void save_state (ICard card) {
            var widget = card.widget;
            var anim_card = card as AnimatedCard;

            if (widget != null) {
                anim_card.width = get_allocated_width ();
                anim_card.height = get_allocated_height ();
                if (widget is AnimatableAdapter) {
                    anim_card.opacity = (widget as AnimatableAdapter).opacity;
                }
            }
        }

        protected bool get_state (ICard card, out int width, out int height) {
            var result = false;
            var widget = card.widget;

            if (widget != null) {
                var tmp_card = card as AnimatedCard;
                width = tmp_card.width;
                height = tmp_card.height;

                result = width > 1 && height > 1;

                if (!result && (tmp_card.width_request > 1 && tmp_card.height_request > 1) ){
                    result = true;
                    width = tmp_card.width_request;
                    height = tmp_card.height_request;
                }

            } else {
                width = 0;
                height = 0;
            }

            return result;
        }
    }
}
