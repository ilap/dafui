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

namespace Daf.UI.Widgets {

    public class Card : Object, ICard {

        public Widget? widget { get; set; default = null; }

        public bool visible { get; set; default = false; }

        public Align halign { get; set; default = Align.START; }
        public Align valign { get; set; default = Align.START; }

        public bool hexpand { get; set; default = true; }
        public bool vexpand { get; set; default = true; }

        public Widget? focus_child { get; set; default = null; }

        public class Card (Widget widget) {
            this.widget = widget;
        }
      }
}

