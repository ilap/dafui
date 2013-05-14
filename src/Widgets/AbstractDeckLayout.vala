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

namespace Daf.UI.Widgets {

    public abstract class AbstractDeckLayout : Container, IDeckLayout {

        public uint size { get { return cards.length (); }}

        public Widget? active_widget {
            get {
                   if (active_card != null) {
                       return active_card.widget;
                } else {
                    return null;
                }
            }
            private set {

            }
        }

        public ICard? active_card { get; set; default = null; }

        private  unowned List<ICard> cards = null;

        public class AbstractDeckLayout () {
            this.with_cards (new List<ICard> ());
        }

        public class AbstractDeckLayout.with_cards (List<ICard> cards) {
            this.cards = cards;
            set_has_window (false);
        }

        ~DeckLayout () {
           //TODO: foreach (var card in cards) {
           // remove_card (card);
            // }
        }

        public override void add (Widget widget) {

            if (get_card_of_widget (widget) == null) {

                // Abstract method for Card creation...
                var card = create_card (widget);
                lock (cards) {
                      cards.append (card);
                   }

                 if (active_card == null) {
                    card.visible = true;
                       active_card = card;
                }
            } else {
                // FIXME: It's been already added.
            }
        }

        public override void remove (Widget widget) {

            // Active cards null means empty cards.
            if (active_card == null || widget == null) {
                return;
            }

            var card = get_card_of_widget (widget);

            if (card == null) {
                return;
            }

            var was_visible = card.visible;

            if (card == active_card) {
                // We need to switch to the next card.
                var next_card = get_next_card (active_card);
                if (next_card != null) {
                    clone_card (active_card, next_card);
                    do_switch (next_card);
                } else {
                    // Means was not any prev and next card.
                    active_card = null;
                }
            }

            remove_card (card);

            if (was_visible) {
                queue_resize ();
            }
        }

        private void remove_card (ICard card) {

            var widget = card.widget;
            if (widget != null) {
                widget.unparent ();
            }

            card.widget = null;
            lock (cards) {
                cards.remove (card);
            }
        }

        private void clone_card (ICard from, ICard to) {
            to.visible = from.visible;

            to.halign = from.halign;
            to.valign = from.valign;

            to.hexpand = from.hexpand;
            to.vexpand = from.vexpand;

            var to_card = to as AnimatedCard;
            var from_card = from as AnimatedCard;

            to_card.width_request = from_card.width_request;
            to_card.height_request = from_card.height_request;

            to_card.height = from_card.height;
            to_card.width = from_card.width;
            to_card.opacity = from_card.opacity;
        }

        private ICard? get_next_card (ICard? card) {

            var result =  get_next (card);

            if (result == null) {
                result = get_next (card, false);
            }

            return result;
        }

        protected ICard? get_card_of_widget (Widget? widget) {
            ICard? result = null;

            foreach (var card in cards) {
                if (card.widget == widget) {
                    result = card;
                    break;
                }
            }
            return result;
        }

        private ICard? get_next (ICard? card, bool is_next = true) {
            ICard? result = null;
            unowned List<ICard>? card_node = null;

            lock (cards) {
                if (card != null && cards != null && (card_node = cards.find (card)) != null) {
                    unowned List<ICard>? next = is_next ? card_node.next : card_node.prev;
                    if (next != null) {
                        result = next.data;
                    }
                }
            }
            return result;
        }

        private bool cards_are_valid (ICard? card) {
            return card != null && card.widget != null && active_card != null && active_card.widget != null;
        }

        public void switch_next (bool quiet = false) {
            var next_card = get_next_card (active_card);
            if (cards_are_valid (next_card)) {
                do_switch (next_card, quiet);
            }
        }

        public bool switch_widget (Widget? widget, bool quiet = false) {
            debug ("switch_widget");

            var card = get_card_of_widget (widget);

            var result = card != null;

            if (result) {
                lock (active_card) {
                    // kick off the abstract method...
                    if (cards_are_valid (card) && active_card != card) {
                        result = do_switch (card, quiet);
                    }
                }
            }
            return result;
        }

        public override void forall_internal (bool include_internal, Gtk.Callback callback) {

            if (active_card == null) {
                return;
            }

            if (active_card.widget != null) {
                callback (active_card.widget);
            }

            foreach (var card in cards) {
                var widget = card.widget;

                if (widget != null && widget != active_card.widget) {
                    callback (widget);
                }
            }
        }

        // Abstract methods.
        protected abstract bool do_switch (ICard? to_card, bool quiet = true);
        protected abstract ICard create_card (Widget widget);

        protected abstract void compute_width (ICard card, out int minimum, out int natural);
        protected abstract void compute_height (ICard card, out int minimum, out int natural);
        // Overrided methods.

        public override bool draw (Cairo.Context cr) {

            foreach (var card in cards) {
                if (card.visible && card.widget != null) {
                    propagate_draw (card.widget, cr);
                }
            }
            return false;
        }

        public  override void get_preferred_width ( out int minimum, out int natural) {

            if (active_card != null && active_card.widget != null && active_card.widget.visible) {
                // Abstract method...
                compute_width (active_card, out minimum, out natural);
                //active_card.widget.get_preferred_width (out minimum, out natural);
            } else {
                minimum = 5;
                natural = 5;
            }
        }

        public  override void get_preferred_height (out int minimum, out int natural) {

            if (active_card != null && active_card.widget != null && active_card.widget.visible) {
                compute_height (active_card, out minimum, out natural);
                //active_card.widget.get_preferred_height (out minimum, out natural);
            } else {
                minimum = 5;
                natural = 5;
            }
        }

        public override void size_allocate (Allocation alloc) {

            set_allocation (alloc);
            print_alloc (this, alloc);

            int border_width = (int) get_border_width ();

            var child_alloc = Allocation ();

              child_alloc.x = alloc.x + border_width;
              child_alloc.y = alloc.y + border_width;
            child_alloc.width = int.max (1, alloc.width - 2 * border_width);
            child_alloc.height = int.max (1, alloc.height - 2 * border_width);

            if (active_card != null && active_card.widget != null) {
                print_alloc (active_card.widget, child_alloc);
                active_card.widget.size_allocate (child_alloc);
            }
        }

        public void print_alloc (Widget w, Allocation a) {
            debug ("%s: x: %d, y: %d, w: %d, h: %d", w.name, a.x, a.y, a.width, a.height);
        }
    }
}
