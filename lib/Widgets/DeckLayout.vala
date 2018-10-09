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

    public class DeckLayout : AbstractDeckLayout {

        protected override bool do_switch (ICard? to_card, bool quiet = true) {

            active_card.widget.set_child_visible (false);
            active_card.visible = false;

            active_card = to_card;
            active_card.widget.set_child_visible (true);
            active_card.visible = true;

            return true;
        }

        protected override ICard create_card (Widget widget) {

            widget.set_parent (this);
            var card = new Card (widget);

            return card;
        }

        protected override void compute_width (ICard card, out int minimum, out int natural) {
            card.widget.get_preferred_width (out minimum, out natural);
        }

        protected override void compute_height (ICard card, out int minimum, out int natural) {
            card.widget.get_preferred_width (out minimum, out natural);
        }
    }
}