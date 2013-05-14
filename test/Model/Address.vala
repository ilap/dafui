// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
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
 */

namespace Daf.UI.Test.Model {

    public class Address : Object {

        public string street_number { get; set; }
        public string street_name { get; set; }
        public int post_code { get; set; }
        public string suburb { get; set; }
        public string city { get; set; }

        public Address (string street_number = "",
                        string street_name = "",
                        int post_code = 0,
                        string suburb = "",
                        string city = "") {
            this.street_number = street_number;
            this.street_name = street_name;
            this.post_code = post_code;
        }
    }
}
