//
// Copyright 2022 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI
import WysiwygComposer

extension WysiwygAction: CaseIterable, Identifiable {
    public static var allCases: [WysiwygAction] = [
        .bold, .italic, .strikeThrough, .underline, .inlineCode,
        .link(url: "unset"), .undo, .redo, .orderedList, .unorderedList,
    ]

    public var id: String {
        accessibilityIdentifier.rawValue
    }

    /// Compute color for action button.
    ///
    /// - Parameter viewModel: Composer's view model.
    /// - Returns: Tint color that the button should use.
    public func color(_ viewModel: WysiwygComposerViewModel) -> Color {
        let isDisabled = isDisabled(viewModel)
        // Buttons for reversed actions should be highlighted with a specific colour.
        let isActive = viewModel.reversedActions.contains(composerAction)
        switch (isDisabled, isActive) {
        case (true, _):
            return .black.opacity(0.3)
        case (false, true):
            return .blue
        case (false, false):
            return .black
        }
    }

    /// Compute disabled status for action.
    ///
    /// - Parameter viewModel: Composer's view model.
    /// - Returns: True if the action is disabled, false otherwise.
    public func isDisabled(_ viewModel: WysiwygComposerViewModel) -> Bool {
        viewModel.disabledActions.contains(composerAction)
    }

    var accessibilityIdentifier: WysiwygSharedAccessibilityIdentifier {
        switch self {
        case .bold:
            return .boldButton
        case .italic:
            return .italicButton
        case .strikeThrough:
            return .strikeThroughButton
        case .underline:
            return .underlineButton
        case .inlineCode:
            return .inlineCodeButton
        case .link:
            return .linkButton
        case .undo:
            return .undoButton
        case .redo:
            return .redoButton
        case .orderedList:
            return .orderedListButton
        case .unorderedList:
            return .unorderedListButton
        }
    }

    /// Returns the name of the system icon that should be used for button display.
    var iconName: String {
        switch self {
        case .bold:
            return "bold"
        case .italic:
            return "italic"
        case .strikeThrough:
            return "strikethrough"
        case .underline:
            return "underline"
        case .inlineCode:
            return "chevron.left.forwardslash.chevron.right"
        case .link:
            return "link"
        case .undo:
            return "arrow.uturn.backward"
        case .redo:
            return "arrow.uturn.forward"
        case .orderedList:
            return "list.number"
        case .unorderedList:
            return "list.bullet"
        }
    }
}

extension WysiwygAction: Equatable {
    public static func == (lhs: WysiwygAction, rhs: WysiwygAction) -> Bool {
        switch (lhs, rhs) {
        case let (.link(url: lhsUrl), .link(url: rhsUrl)):
            return lhsUrl == rhsUrl
        default:
            return lhs.id == rhs.id
        }
    }
}

private extension WysiwygAction {
    private var composerAction: ComposerAction {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case .strikeThrough:
            return .strikeThrough
        case .underline:
            return .underline
        case .inlineCode:
            return .inlineCode
        case .link:
            return .link
        case .undo:
            return .undo
        case .redo:
            return .redo
        case .orderedList:
            return .orderedList
        case .unorderedList:
            return .unorderedList
        }
    }
}
