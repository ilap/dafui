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
     * The animation modes used by TimeLine and Animator.
     *
     * The following of animation types (easing equation, transition types)
     * have been adopted from Clutter.
     *
     * Check the following for further information:
     * @link http://www.robertpenner.com/easing/penner_chapter7_tweening.pdf
     */
    public enum AnimationMode {

        /* linear tweening */
        LINEAR,

        /* quadratic tweening */
        EASE_IN_QUAD,
        EASE_OUT_QUAD,
        EASE_IN_OUT_QUAD,

        /* cubic tweening */
        EASE_IN_CUBIC,
        EASE_OUT_CUBIC,
        EASE_IN_OUT_CUBIC,

        /* quartic tweening */
        EASE_IN_QUART,
        EASE_OUT_QUART,
        EASE_IN_OUT_QUART;

        /**
         * The alpha values computed by the alpha/easing function.
         */
        public double easing_func (uint64 elapsed, uint64 duration)
                requires ((this == LINEAR &&
                            0f <= (double) (elapsed / duration) <= 1f) ||
                            (this != LINEAR &&
                            (-1f <= (double) (elapsed / duration) <= 2f))) {

            double p = (double) ((double) elapsed / (double) duration);

            switch (this) {

                /* linear */
                case LINEAR:
                    break;

                /* quadratic */
                case EASE_IN_QUAD:
                      p *= p;
                    break;

                case EASE_OUT_QUAD:
                    p = -1f * p * (p - 2f);
                    break;

                case EASE_IN_OUT_QUAD:
                    p *= 2;

                    if (p < 1f) {
                        p = 0.5 * p * p;
                    } else {
                        p -= 1f;
                        p = -0.5 * (p * (p - 2f) - 1f);
                    }
                    break;

                /* cubic */
                case EASE_IN_CUBIC:
                    p = p * p * p;
                    break;

                case EASE_OUT_CUBIC:
                    p -= 1f;
                    p = p * p * p + 1f;
                    break;

                case EASE_IN_OUT_CUBIC:
                    p *= 2f;

                    if (p < 1f) {
                        p = 0.5 * p * p;
                    } else {
                        p -= 2f;
                        p = 0.5 * (p * p * p + 1f);
                    }
                    break;

                /* quartic */
                case EASE_IN_QUART:
                    p = p * p * p * p;
                    break;

                case EASE_OUT_QUART:
                    p -= 1f;
                    p = -1f - (p * p * p * p -1f);
                    break;

                case EASE_IN_OUT_QUART:
                    p *= 2f;

                    if (p < 1f) {
                        p = 0.5 * p * p * p * p;
                    } else {
                        p -= 2f;
                        p = -0.5 * (p * p * p * p -2);
                    }
                    break;

                /* default */
                default:
                    assert_not_reached ();
            }
            return p;
        }
    }
}
