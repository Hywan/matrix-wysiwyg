// Copyright 2022 The Matrix.org Foundation C.I.C.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#![cfg(test)]

use crate::tests::testutils_composer_model::cm;
use crate::ToTree;

#[test]
fn single_nested_tag_produces_tree() {
    let model = cm("<b>abc<i>def</i></b>|");
    assert_eq!(
        model.state.dom.to_tree(),
        r#"
├>b
│ ├>"abc"
│ └>i
│   └>"def"
└>""
"#,
    );
    // TODO: trailing "" needs fixing in parse
}

#[test]
fn multiple_tags_nested_inside_one_produce_tree() {
    let model =
        cm("<ul><li>ab</li><li><b>cd</b></li><li><i><b>ef|</b></i></li></ul>");
    assert_eq!(
        model.state.dom.to_tree(),
        r#"
└>ul
  ├>li
  │ └>"ab"
  ├>li
  │ └>b
  │   └>"cd"
  └>li
    └>i
      └>b
        └>"ef"
"#,
    );
}

#[test]
fn tree_display_converts_zwsp() {
    let model = cm("<ol><li>ab</li><li>\u{200b}cd|</li></ol>");
    assert_eq!(
        model.state.dom.to_tree(),
        "
└>ol
  ├>li
  │ └>\"ab\"
  └>li
    └>\"~cd\"
",
    );
}

#[test]
fn br_within_text_shows_up_in_tree() {
    let model = cm("a<br />|b");
    assert_eq!(
        model.state.dom.to_tree(),
        r#"
├>"a"
├>br
└>"b"
"#,
    );
}
