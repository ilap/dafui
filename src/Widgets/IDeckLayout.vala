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
    public interface IDeckLayout : Container {

        public abstract void add (Widget widget);
        public abstract void remove (Widget widget);

        public abstract bool switch_widget (Widget? widget, bool quiet = false);
        //public abstract bool switch_widget_at (int position);

        //public abstract Widget? get_active_widget ();
        //public abstract Widget? get_widget_at (int position);

        public abstract bool do_switch (ICard? card, bool quiet = true);
        protected abstract ICard create_card (Widget widget);
    }
}

