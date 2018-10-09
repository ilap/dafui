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

namespace Daf.UI.Animation {

    /**
     * Keyframe class to hold the initial, computed and final values of a property.
     * The initial value will be computed on the start of the animation.
     *
     * I had to implement the keyframe as I got some issues /w animations
     * (widget is flickering) when a Widget is centered and the parent is resizing.
     */
    public class KeyFrame {
        public double prev_key;
        public double key;

        public Type type;

           public Value final;
           public Value initial;

           public KeyFrame (double key, double prev_key, Type type, Value initial, Value final) {

            this.key = key;
            this.prev_key = prev_key;

            this.type = type;

            this.initial = Value (type);
            this.initial = initial;

            this.final = Value (type);
            this.final = final;
        }
     }
}