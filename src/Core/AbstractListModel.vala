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
using Gtk;

using Daf.Core;

namespace Daf.UI.Core {

    /**
     * FIXME: HashMap not properly inmplemented nor finished yet.
     **/
    public class  AbstractListModel<G> :  AbstractValueHolder, TreeModel {

        private ArrayListModel<G> array_list;

        protected int num_columns = 2;
        protected int stamp = 0;

        public AbstractListModel (ArrayListModel<G> array_list) {
            stamp = (int) Random.next_int ();
            this.array_list = array_list;
        }

        /** Interfaces */
        public bool get_iter (out TreeIter iter, TreePath path) {
            weak int[] indices;
            int depth;
            var result = false;

            indices = path.get_indices ();
            int key = indices[0];

            iter = TreeIter ();
            iter.stamp = stamp;

            if (0 <= key < array_list.size) {
                iter.user_data = (void *) key;
                result = true;
            }
            debug ("get_iter ARRAYLIST SIZE:%d\n", array_list.size);

            return result;
        }

        public  bool iter_children (out TreeIter iter, TreeIter? parent) {
            debug ("iter_children\n");
            return false;
        }

        public  bool iter_has_child (TreeIter iter) {
            debug ("iter_has_child\n");
            return false;
        }

        public  bool iter_next (ref TreeIter iter) {

            int key = (int) iter.user_data;

            debug ("iter_next: KEEY: %d, ARRAY SIZE: %d", key, array_list.size);
            if (key < 0 || key >= array_list.size - 1) return false;

            (int) iter.user_data++;// = (key + 1);
            debug ("iter_next %d .. new key %d\n", key, (int) iter.user_data);

            return true;
        }

        public  bool iter_nth_child (out TreeIter iter, TreeIter? parent, int n) {
            debug ("iter_nth_child: %d\n", n);
            return false;
        }

        public  bool iter_parent (out TreeIter iter, TreeIter child) {

            debug ("iter_parent\n");
            return false;
        }

        public  int get_n_columns () {
            debug ("get_n_columns\n");
            return num_columns;
        }

        public  int iter_n_children (TreeIter? iter) {
            debug ("iter_n_child_children\n");
            return array_list.size;
        }

        public  TreeModelFlags get_flags () {
            debug ("get_flags\n");
            return TreeModelFlags.LIST_ONLY;// | TreeModelFlags.ITERS_PERSIST;
        }

        public  TreePath? get_path (TreeIter iter) {
            int pos = (int) iter.user_data;
            debug ("get_path stamp: %d get_path: %d\n", iter.stamp, pos);

            var tree_path = new TreePath ();

            tree_path.append_index (pos);
            return tree_path;
        }

        public  Type get_column_type (int index) {
            debug ("get_column_type %d", index);
            return typeof (string);
        }

        public void get_value (TreeIter iter, int column, out Value val) {

            int key = (int) iter.user_data;
            debug ("Get value1: KeyFile: %d Columnn %d", key, column);

            if (key >= array_list.size) return;


            //val.init (typeof(string));
            //val = "selection_in_list";
            //val.init (typeof (Object));
            Object o = (Object) array_list.get (key);
            //val = get_val ();
            val = (string) read_property (o, "first_name");
            //.changed ("Got value1: KeyFile: %d\n", key);

        }

        private Value? read_property (Object? object, string property_name) {
            //.changed ("do_read_property");
            ParamSpec? param_spec = object.get_class ().find_property (property_name);
            assert (param_spec != null);

            // debug ("TYPE %s", param_spec.name);
            Value model_value = Value (param_spec.value_type);

            object.get_property (property_name, ref model_value);
           // FIXME:
            if (model_value.strdup_contents () == "NULL") {
                return null;
            } else {
                return model_value;
            }
        }



        public bool get_iter_first (out TreeIter iter) {
            debug ("get_iter_first\n");
            return false;
        }

        public bool get_iter_from_string (out TreeIter iter, string path_string) {
            debug ("get_iter_from_string\n");
            return true;
        }

        public string get_string_from_iter (TreeIter iter) {
            debug ("get_string_from_iter\n");
            return "";
        }

         public virtual bool iter_previous (ref TreeIter iter) {
             debug ("iter_prev\n");
            return false;
        }

        public virtual void ref_node (TreeIter iter) {
            debug ("ref_node stamp: %d :%d\n", iter.stamp, (int) iter.user_data);
        }

        public virtual void unref_node (TreeIter iter) {
            debug ("unref_node\n");
        }

        public void foreach (TreeModelForeachFunc func) {

        }

        public new void get (TreeIter iter, ...) {
            debug ("get\n");
        }

        public void get_valist (TreeIter iter, void* var_args) {
            debug ("get_va_list\n");
        }
    }
}