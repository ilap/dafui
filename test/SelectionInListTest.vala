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

using Daf.Core;
using Daf.UI.Core;
using Daf.UnitTest;
using Daf.UI.Test.Model;

namespace Daf.UI.Test {

    public class SelectionInListTest : AbstractTestCase {

        IListModel<Person> array_list;
        public SelectionInListTest () {
            base ("SelectionInListTest");

            add_test ("empty_selection_list_test",
                                empty_selection_list_test);
            add_test ("empty_selection_list_with_model_presenter_test",
                                empty_selection_list_with_model_presenter_test);
            add_test ("selection_list_with_model_presenter_test",
                                selection_list_with_model_presenter_test);
        }

        public override void set_up () {
        }

        public override void tear_down () {
        }

        public void empty_selection_list_test () {
            var person_a = new Person ("Felix", "Van der Gullen");
            var person_b = new Person ("Ignaz", "rebitsch-Lincoln");

            array_list = new ArrayListModel<Person> ();


            var selection =
                   new SelectionInList<Person>.with_list_model (array_list);
            debug ("Back off...");
            selection.notify[IValueModel.PROP_NAME].connect (() => { debug ("Value has.changed");});


            var has_selection = new IsNotNullConverter (selection);

            assert (!(bool) has_selection.get_val ());

               array_list.add (person_a);
            array_list.add (person_b);
            selection.set_val (array_list.get_at (0));
            assert ((bool) has_selection.get_val ());

        }

        public void empty_selection_list_with_model_presenter_test () {

            var person_a = new Person ("Felix", "Van der Gullen");
            var person_b = new Person ("Ignaz", "rebitsch-Lincoln");

            var array_list = new ArrayListModel<Person> ();
            //array_list.add (person_a);
            //array_list.add (person_b);

            var selection =
                   new SelectionInList<Person>.with_list_model (array_list);

            selection.notify[IValueModel.PROP_NAME].connect (() => { debug ("Value has.changed");});

              var has_selection = new IsNotNullConverter (selection);

            assert (!(bool)has_selection.get_val ());

            //array_list.add (person_a);

            //selection.set_val (person_a);
            //assert ((bool) has_selection.get_val ());


            var presenter = new ModelPresenter (selection);

            var first_name = presenter.get_value_model ("first_name");
            assert (first_name.get_val () == null);

            /*
            // TODO: should throw some exception...
            try {
                var first_name = presenter.get_value_model ("first_name");
              } catch (ValueModelException.NO_OBJECT error) {
                  // bla... bla..
              }
              */
            //assert ((string) first_name.get_val () == "Felix");

            //selection.set_val (array_list.get (1));
            //assert ((string) first_name.get_val () == "Ignaz");

        }

        public void selection_list_with_model_presenter_test () {

            var person_a = new Person ("Felix", "Van der Gullen");
            var person_b = new Person ("Ignaz", "rebitsch-Lincoln");

            var array_list = new ArrayListModel<Person> ();
            array_list.add (person_a);
            array_list.add (person_b);

            var selection =
                   new SelectionInList<Person>.with_list_model (array_list);
            //selection.notify[IValueModel.PROP_NAME].connect (() => { debug ("Value has.changed");});

            //var has_selection = new IsNotNullConverter (selection);

            //assert (!(bool)has_selection.get_val ());

            //selection.set_val (array_list.get_at (0));
            //assert ((bool) has_selection.get_val ());


             //var presenter = new ModelPresenter (selection);

            /*var first_name = presenter.get_value_model ("first_name");
            assert ((string) first_name.get_val () == "Felix");

            selection.set_val (array_list.get_at (1));
            assert ((string) first_name.get_val () == "Ignaz");*/
        }

        /*
         * Nested Classe for checking not null
         */
        public class IsNotNullConverter : AbstractTypeConverter {

            public IsNotNullConverter (IValueModel value_model) {
                base (value_model);
            }

            public override Value convert_from_model (Value? model_value) {
                return (bool) (model_value != null);
            }

            public override void set_val (Value? new_value) {
                model.set_val (new_value == null);
            }
        }

        public void test () {
            message ("Alma");
        }
    }
}
