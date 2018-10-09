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
     * Adopted the Clutter like API/Class.
     */
    public class TimeLine : Object, IAnimatable {

        // Properties
        private uint _fps;
        public uint fps {
            get { return _fps; }
            set {  _fps = 0 < value <= 60 ?  value : 25; }
        }
        public uint64 duration { get; set; default = 1000; }

        // Private fields
        public AnimationMode mode  = AnimationMode.LINEAR;

        private uint timeout_handler = 0;

        private bool is_first_frame = true;

        private uint64 frame_time;
        private uint64 delta_time;
        private uint64 elapsed_time;

        private bool _playing = false;
        public bool playing {
            get { return _playing; }
            private set {
                if (_playing == value) {
                    return;
                }

                _playing = value;

                if (_playing) {
                    is_first_frame = true;

                    timeout_handler = Timeout.add ((uint) (1000/fps), next_frame_timer);
                } else {

                    Source.remove (timeout_handler);
                    timeout_handler = 0;
                }
            }
        }

        public TimeLine (AnimationMode mode) {
            this.mode = mode;
        }

        public TimeLine.full (AnimationMode mode, uint duration, uint fps = 25) {
            this.mode = mode;
            this.duration = duration;
            this.fps = fps;
        }

        public void stop () {
            if (!playing) {
                return;
            }

            delta_time = 0;
            playing = false;
        }

        public void start () {

            if (duration == 0 || playing) {
                return;
            }

            before_started ();
            delta_time = 0;
            playing = true;

            started ();
        }

        // TODO: Check why the get_real_time () is behaving dodgy (16ms issue?)..
        private static inline uint64 tv2ms (TimeVal tv) {
            return tv.tv_sec * 1000 + tv.tv_usec / 1000;
        }

        private  bool next_frame_timer () {
            if (timeout_handler == 0) {
                return false;
            }

            // It's behaving dodgy, use an internal inline func instead.
            //do_tick (get_real_time ());
            do_tick (tv2ms (TimeVal ()));

            return true;
        }

        private void do_tick (uint64 tick_time) {
            if (!playing) {
                return;
            }

            if (is_first_frame) {

                frame_time = tick_time;
                delta_time = 0;
                is_first_frame = false;
            } else {
                var msecs = tick_time - frame_time;

                frame_time += msecs;
                delta_time = msecs;
            }

            debug ("delta: %d, tick_time: %d", (int) delta_time, (int) elapsed_time);
            do_frame ();
        }

        public bool do_frame () {

            elapsed_time += delta_time;

            double progress;

            if (elapsed_time < duration) {
                progress = mode.easing_func (elapsed_time.clamp (0, duration), duration);
                new_frame (progress);

                return playing;
            } else {
                playing = false;
                new_frame (1f);
                elapsed_time = 0;

                completed ();

                return true;
            }
        }

        /* Signals */
        public virtual signal void new_frame (double progress) {
            // TODO:...
            debug ("TimeLine new_frame");
        }

        public virtual signal void started () {
            // TODO:...
            debug ("TimeLine started");
        }

        public virtual signal void completed () {
            // TODO:...
            debug ("TimeLine completed");
        }

        public virtual signal void before_started () {
            // TODO:...
            debug ("TimeLine before_started");
        }
    }
}