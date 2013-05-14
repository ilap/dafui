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

using Gee;

namespace Daf.UI.Animation {

    [CCode (has_target = false)]
    public delegate void ProgressFunc (Value initial, Value final, double progress, ref Value value);

    /**
     * This solution is adopted the idea of the implicit animation of Clutter.
     */
    public class PropertyAnimator : Object {

        private Object? object;
        public TimeLine? timeline { get; set; }

        public HashMap<string, ArrayList<KeyFrame>> properties_map =  new HashMap<string, ArrayList<KeyFrame>> ();

        private PropertyAnimator (Object object, TimeLine timeline) {
            this.object = object;
            this.timeline = timeline;
            this.timeline.new_frame.connect (on_new_frame);
            this.timeline.started.connect (on_started);
            this.timeline.completed.connect (on_completed);
        }

        ~PropertyAnimator () {

            foreach (var property in properties_map.entries) {
                Gee.List<KeyFrame> keyframes = property.value;

                keyframes.clear ();
            }

            if (timeline != null) {
                timeline.stop ();
                timeline.new_frame.disconnect (on_new_frame);
                timeline.started.disconnect (on_started);
                timeline.completed.disconnect (on_completed);
            }

            if (object != null) {
                object = null;
            }
        }

        private static HashMap<Type, ProgressFunc> progress_funcs { get; protected set; }

        static construct {

            progress_funcs = new HashMap<Type, ProgressFunc> ();

            // Boolean ("true" if p >= 0.5, "false" if p < 0.5)
            progress_funcs.set (typeof (bool), (i, f, p, ref v) => {
                int i1 = (int) ((bool) i);
                int f1 = (int) ((bool) f);

                  double tmp_val =   (double) (p * (f1 -  i1) + i1);
                v = tmp_val < 0.5 ? false : true;
            });
            progress_funcs.set (typeof (int), (i, f, p, ref v) => { v =   (int) (p * ((int) f - (int) i) + (int) i); });
            progress_funcs.set (typeof (uint), (i, f, p, ref v) => { v =   (uint) (p * ((uint) f - (uint) i) + (uint) i); });
            progress_funcs.set (typeof (int64), (i, f, p, ref v) => { v =   (int64) (p * ((int64) f - (int64) i) + (int64) i); });
            progress_funcs.set (typeof (uint64), (i, f, p, ref v) => { v =   (uint64) (p * ((uint64) f - (uint64) i) + (uint64) i); });
            progress_funcs.set (typeof (long), (i, f, p, ref v) => { v =   (long) (p * ((long) f - (long) i) + (long) i); });
            progress_funcs.set (typeof (ulong), (i, f, p, ref v) => { v =   (ulong) (p * ((ulong) f - (ulong) i) + (ulong) i); });
            progress_funcs.set (typeof (float), (i, f, p, ref v) => { v =   (float) (p * ((float) f - (float) i) + (float) i); });
            progress_funcs.set (typeof (double), (i, f, p, ref v) => { v =   (double) (p * ((double) f - (double) i) + (double) i); });
        }

        public bool has_proprety () {
            return true;
        }

        public signal void started () ;
        public signal void on_keyframe (string prope_name, double key);

        public signal void completed ();

        public static PropertyAnimator animate (Object object, AnimationMode mode, int duration, ...) {
            var args = va_list ();

            // BUG: The static animate_with_timeline cannot be used here as Vala probably
            // has some va_list copy bug/feature.
            var result = new PropertyAnimator (object, new TimeLine.full (mode, duration));
            result.initialize_properties (object, args);

            return result;
        }

        public static PropertyAnimator animate_with_timeline (Object object, TimeLine timeline, ...) {
            var args = va_list ();

            var result = new PropertyAnimator (object, timeline);
            result.initialize_properties (object, args);

            return result;
        }

        private void compute_initial_values () {
            string prop_name;
            KeyFrame keyframe;
            Gee.List keyframes;

            foreach (var prop_map in properties_map.entries) {
                prop_name = prop_map.key;
                keyframes = prop_map.value;
                keyframe = get_act_keyframe (keyframes);

                object.get_property (prop_name, ref keyframe.initial);
            }
        }

        public void remove_keyframe (double key, string property)
            requires ( 0f < key < 1f) {

            debug ("key: %f, property: %s", key, property);

            if (properties_map.has_key (property)) {

                Gee.List<KeyFrame> keyframes = properties_map.get (property);

                //lock (keyframes) {
                // FIXME it could lead to some unwanted condition...
                foreach (var keyframe in keyframes) {

                    if (key == keyframe.key) {
                        keyframes.remove (keyframe);
                        break;
                    }
                }
                //}
            }
        }

        public void set_keyframe (double key, string property, Value final)
            requires ( 0f <= key <= 1f) {

            // If the property key does not exist in the map it means: not initialized.
            if (properties_map.has_key (property)) {

                Gee.List<KeyFrame> keyframes = properties_map.get (property);

                foreach (var keyframe in keyframes) {

                    if (key <= keyframe.key) {

                        /////////////////////////////////////////////////////////////////////
                        // Dirty hack again. As Vala somewhy initializes a gdouble as gfloat despite the
                        // Value (keyframe.type). keyframe.type == gdouble.
                        Value initial = Value (keyframe.type);
                        initial = keyframe.initial;

                        Value reset_final = Value (keyframe.type);

                        if ((final.type () != reset_final.type ()) &&
                            Value.type_transformable (final.type (), reset_final.type ())) {

                            final.transform (ref reset_final);

                        } else {
                            reset_final = final;
                        }
                        ///////////////////////////////////////////////////////////////////////

                        if (key < keyframe.key) {
                            var new_keyframe = new KeyFrame (key, keyframe.prev_key, keyframe.type, keyframe.initial, reset_final);

                            keyframe.initial = reset_final;
                            keyframe.prev_key = key;

                            int index = keyframes.index_of (keyframe);
                            keyframes.insert (index, new_keyframe);


                        } else {
                            // Updating the existing final value.
                            keyframe.final = reset_final;
                        }
                    break;
                    }
                }
            }
        }

        private KeyFrame? get_act_keyframe (Gee.List<KeyFrame> keyframes, double progress = 0f)
            requires (0f <= progress <= 1f) {

            debug ("get_act_keyframe");
            KeyFrame? result = keyframes.last ();

            foreach (var keyframe in keyframes) {
                if (progress < keyframe.key) {
                    result = keyframe;

                    break;
                }
            }
            return result;
        }

        private void initialize_properties (Object object_ref, va_list args) {
            debug ("Initialize properties");

            if (object != object_ref) {
                return;
            }

            string? prop_name;
            ParamSpec? pspec = null;
            Type prop_type;

            var obj_type = object.get_type ();
            var oc = (ObjectClass) obj_type.class_ref ();

            /**
             * TODO: we should implement finding the child's property in the parent class,
             * but not many widget's (Fixed's x and y, Notebook's child pos, Layout 's x and y etc.)
             * are using this feature.
             * But, It could have some benefits for some custom widgets...
             */
            while ((prop_name = args.arg ()) != null ) {

                pspec = oc.find_property (prop_name);

                if (pspec != null) {
                    prop_type = pspec.value_type;
                    var final_value = Value (prop_type);

                    // This is a real bad hacking  as there is no such G_VALUE_COLLECT like macros in vala.
                    // We have two options yet:
                    // Use floating values as parameter values like 0f 0.0 etc
                    // or using this parsing below.
                    // I prefer the 1st option but implemented the 2nd one now.

                    if (parse_value (ref final_value, args)) {
                        var initial_value = Value (prop_type);
                        initial_value.reset ();

                        // Initial keyframe. key = 1f, prev_key = 0f;
                        var keyframe = new KeyFrame (1f, 0f, prop_type, initial_value, final_value);

                        var keyframes = new ArrayList<KeyFrame> ();

                        keyframes.insert (0, keyframe);
                        properties_map.set (prop_name, keyframes);
                    } else {
                        //TODO: throw error and return as the va_list is inconsistent.
                        critical ("Error on initialize properties");
                        return;
                    }

                } else {
                    //TODO: Check whether its parent has this property and throw error
                    // if it does not have.
                    // Also return as the va_list is inconsistent as we do not know the type of the property...
                    critical ("Error on initialize properties, PropertyAnimator name: %s", prop_name);
                    return;
                }
            }


        }

        // This is really dirty solution, but unfortunately Vala does not support
        // type safe params and G_VALUE_COLLECT* macros.
        private bool parse_value (ref Value val, va_list args) {

            Type type = val.type ();
            bool result = true;

            if (type == typeof (bool)) {
                val = args.arg<bool> ();
            } else if (type == typeof (int)) {
                val = args.arg<int> ();
            } else if (type == typeof (uint)) {
                val = args.arg<uint> ();
            } else if (type == typeof (int64)) {
                val = args.arg<int64> ();
            } else if (type == typeof (uint64)) {
                val = args.arg<uint64> ();
            } else if (type == typeof (long)) {
                val = args.arg<long> ();
            } else if (type == typeof (ulong)) {
                val = args.arg<ulong> ();
            } else if (type == typeof (float)) {
                val = args.arg<float> ();
            } else if (type == typeof (double)) {
                val = args.arg<double> ();
            } else {
                // Unsupported animation property type.
                result = false;
            }

            return result;
        }

        public void on_new_frame (double progress) {
            debug ("progress: %f, (uint) progress * 100: %u", progress, (uint) (progress * 100));

            timeline.freeze_notify ();

            string prop_name;

            foreach (var property in properties_map.entries) {
                prop_name = property.key;
                Gee.List<KeyFrame> keyframes = property.value;

                KeyFrame? keyframe = get_act_keyframe (keyframes, progress);
                var value = Value (keyframe.type);

                if (progress_funcs.has_key (keyframe.type)) {

                    var progress_func = progress_funcs.get (keyframe.type);

                    double frame_progress;

                    frame_progress = (progress - keyframe.prev_key) / (keyframe.key - keyframe.prev_key);


                    progress_func (keyframe.initial, keyframe.final, frame_progress, ref value);
                    object.set_property (prop_name, value);

                    //if (prop_name == "height-request")
                    //.changed ("%s KF: %f ---  %f --- %f -- %f - %d", prop_name, progress, keyframe.prev_key, keyframe.key, frame_progress, (int) value);

                } else {
                    // throw some information/error message.
                }
            }
            timeline.thaw_notify ();
        }

        private void on_started () {
            timeline.before_started ();
            timeline.freeze_notify ();
            debug ("PropertyAnimator on_started");
            compute_initial_values ();
            timeline.thaw_notify ();
        }

        private void on_completed () {
            debug ("PropertyAnimator on_completed");
        }
    }
}


