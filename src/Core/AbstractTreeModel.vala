/**
 * Copyright (c) 2012-2013 Pal Dorogi <pal.dorogi@gmail.com>
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

    public abstract class  AbstractTreeModel<G> :  Object, TreeModel {
        private TreeSelection _tree_selection;

        public TreeSelection tree_selection {
            get {
                return _tree_selection;
            }
            set {
                if (_tree_selection != value) {
                    if (_tree_selection != null) {
                        _tree_selection.changed.disconnect (on_tree_selection_changed);
                    }
                    // Must be not null...
                    _tree_selection = value;
                    _tree_selection.changed.connect (on_tree_selection_changed);
                }
            }
        }
        public IListModel<G> list_model;

        protected int num_columns;
        protected int stamp = 0;

        public AbstractTreeModel (IListModel list_model, int num_columns) {
            this.num_columns = num_columns;
            this.list_model = list_model;
            this.list_model.list_changed.connect (on_list_changed);
            this.list_model.item_changed.connect (on_item_changed);
            this.list_model.item_added.connect (on_item_added);
            this.list_model.item_removed.connect (on_item_removed);

            if (this.list_model is SelectionInList) {

                (list_model as SelectionInList).notify[IValueModel.PROP_NAME].connect (on_selection_changed);
            }

            stamp = (int) Random.next_int ();
            debug ("AbstractTreeModel construct");
        }

        /** Interfaces */
        public bool get_iter (out TreeIter iter, TreePath path) {
            //.changed ("get_iter: get_path: %s -> depth %d", path.to_string (), path.get_depth ());
            weak int[] indices;
            var result = false;

            indices = path.get_indices ();
            int key = indices[0];
            iter = TreeIter ();
            iter.stamp = 0;

            if (0 <= key < list_model.get_length ()) {
                iter.user_data = (void *) key;
                iter.stamp = stamp;
                result = true;
            }

            return result;
        }

        public bool iter_children (out TreeIter iter, TreeIter? parent) {
            debug ("iter_children");
            iter = TreeIter ();
            iter.stamp = 0;

            if (parent != null || list_model.get_length () == 0) {
                return false;
            } else {
                iter.stamp = stamp;
                iter.user_data = (void*) 0;
                return true;
            }
        }

        public bool iter_has_child (TreeIter iter) {
            debug ("iter_has_child");
            return false;
        }

        public bool iter_next (ref TreeIter iter) {

            int key = (int) iter.user_data;

            debug ("iter_next: KEEY: %d, ARRAY SIZE: %d", key, list_model.get_length ());
            if (key < 0 || key >= list_model.get_length () - 1) return false;

            (int) iter.user_data++;// = (key + 1);
            debug ("iter_next %d .. new key %d", key, (int) iter.user_data);

            return true;
        }

        public bool iter_nth_child (out TreeIter iter, TreeIter? parent, int n) {
            debug ("iter_nth_child: %d size: %d", n, list_model.get_length ());

            iter = TreeIter ();
            iter.stamp = 0;

            if (parent != null) {
                return false;
            }

            if (n >= list_model.get_length ()) {
                return false;
            }



            iter.stamp = stamp;
           // debug ("#### GET -1");
            var aaaa = (void*) list_model.get_at (n);
           // debug ("##### GET 0 %s", (aaaa == null).to_string ());

            //.changed ("NTH CHILD: %s", ((Object) aaaa).get_class ().get_type ().name ());
            //.changed ("USER DATA");
            iter.user_data = (void*) aaaa;
           // debug ("USER DATA END");

            return true;
        }

        public bool iter_parent (out TreeIter iter, TreeIter child) {
            debug ("iter_parent");
            iter = TreeIter ();
            iter.stamp = 0;

            return false;
        }

        public int get_n_columns () {
            debug ("get_n_columns");
            return num_columns;
        }

        public int iter_n_children (TreeIter? iter) {
            debug ("iter_n_child_children");
            if (iter == null) {
                return list_model.get_length ();
            }

            if (iter.stamp != stamp) {
                return -1;
            } else {
                return 0;
            }
        }

        public TreeModelFlags get_flags () {
            debug ("get_flags");
            return TreeModelFlags.LIST_ONLY;// | TreeModelFlags.ITERS_PERSIST;
        }

        public TreePath? get_path (TreeIter iter) {
            debug ("get_path");
               TreePath? result = null;

               if (iter.stamp != stamp) {
                   debug ("returning null: stamp is: %d", iter.stamp);
                   return result;
               }

            int key = (int) iter.user_data;
            if (key >= list_model.get_length ()) {
                debug ("Length is %d", list_model.get_length ());
                return null;
            }

            var tree_path = new TreePath ();

            tree_path.append_index (key);
            debug ("get_path stamp: %s get_path: %d", tree_path.to_string (), key);

            return tree_path;
        }

        public bool check_iter (TreeIter iter) {
            return (int) iter.user_data >= 0 &&
                iter.stamp == stamp;
        }

        // These methods are implemented in the concrete class.
        public abstract Type get_column_type (int index);
        public abstract void get_value (TreeIter iter, int column, out Value val);

        public void on_tree_selection_changed (TreeSelection selection) {
            if (! (list_model is SelectionInList) && list_model.get_length () <= 0 ) {
                return;
            }
            message ("TreeSelection is.changed");
            TreeModel model;
            TreeIter iter;

            if (selection.get_selected (out model, out iter)) {
                debug ("on_tree_selection_changed: iter.stamp is %d, iter.user_data is %d", iter.stamp, (int) iter.user_data);
                if (model == this && check_iter (iter)) {
                    var index = (int) iter.user_data;

                    (list_model as SelectionInList).selection_index = index;
                    //selectio
                    debug ("to select %d", index);
                }
            } else {
                    debug ("No Selection...");

                    (list_model as SelectionInList).selection_index = -1;
            }

            /*&if (list_model is SelectionInList)
                if (selection.get_selected (out model, iter iter)) {
                if (model == selection_)
            }*/

        }

        public void on_item_removed (int index) {
                var path = new TreePath ();
                debug ("Deleting... %d", index);
                path.append_index (index);
                row_deleted (path);
                if (tree_selection != null) {
                    tree_selection.changed ();
                }
        }

       // public void get_path_and_iter (out TreePath path, out TreeIter iter) {
        //}
        public void on_item_added (int index) {
            debug ("item added: index: %d", index);
            var path = new TreePath ();
            var iter = TreeIter ();
            iter.stamp = stamp;
            iter.user_data = (void*) index;
            path.append_index (index);

            row_inserted (path, iter);
            if (tree_selection != null) {
                tree_selection.changed ();
            }
        }
        public void on_list_changed (int size) {
            message ("list_changed, size_t: %d", size);
        }

        public void on_item_changed (int index, G item) {
            debug ("item_changed, index: %d", index);
            var path = new TreePath ();
            var iter = TreeIter ();
            iter.stamp = stamp;
            iter.user_data = (void*) index;
            path.append_index (index);

            row_changed (path, iter);
        }


        public void on_selection_changed (Object sender, ParamSpec param_spec) {

            if (tree_selection == null) {
                return;
            }
            int selection_index = (sender as SelectionInList).selection_index;
            debug ("on_selection_changed: index: %d ", selection_index);

            if (selection_index != -1) {
                TreeIter iter = TreeIter ();
                iter.stamp = stamp;
                iter.user_data = (void*) selection_index;

                tree_selection.select_iter (iter);
            }
        }
    }
}