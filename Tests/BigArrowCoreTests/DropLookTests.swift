import BigArrowCore
import Foundation
import Testing

@Suite("Drop look")
struct DropLookTests {
    @Test("--look parses either case and names the looks when it does not")
    func parsing() throws {
        #expect(try ArrowLook.parse("DROP") == .drop)
        #expect(try ArrowLook.parse("classic") == .classic)
        #expect(throws: BigArrowError.badInput("look 'loud' is not one of classic, drop")) { try ArrowLook.parse("loud") }
    }

    @Test("Drop defaults to acid and sharp corners, classic keeps red and round")
    func defaults() throws {
        #expect(ArrowLook.drop.defaultColor == "acid")
        #expect(ArrowLook.drop.defaultCorners == "sharp")
        #expect(ArrowLook.classic.defaultColor == "red")
        #expect(try ArrowColor.parse(ArrowLook.drop.defaultColor).hex == "#D4FF00")
    }

    @Test("The edge is ink, acid on colours too dark for ink", arguments: ["acid", "flare", "cobalt", "cement", "gum", "ink", "black"])
    func edge(name: String) throws {
        let edge = DropInk.edge(for: try ArrowColor.parse(name))
        #expect(edge == (["ink", "black"].contains(name) ? DropInk.acid : DropInk.ink))
    }

    @Test("A Drop sign's border is its edge unless --border-color says otherwise")
    func borderTint() throws {
        var look = SignAppearance(color: try ArrowColor.parse("cobalt"), size: .medium, corners: .sharp)
        #expect(look.borderTint == ArrowColor(red: 1, green: 1, blue: 1))
        look.look = .drop
        #expect(look.borderTint == DropInk.ink)
        look.borderColor = DropInk.acid
        #expect(look.borderTint == DropInk.acid)
    }

    @Test("A card takes look, defaults its colour by it, and rejects nothing new")
    func card() throws {
        let card = try CardDocument.parse(Data(#"{"title": "Log in", "look": "drop", "rows": [{"type": "text", "value": "hi"}]}"#.utf8))
        #expect(card.arrowLook == .drop)
        #expect(card.colorName == "acid")
        let classic = try CardDocument.parse(Data(#"{"title": "Log in", "rows": [{"type": "text", "value": "hi"}]}"#.utf8))
        #expect(classic.arrowLook == .classic)
        #expect(classic.colorName == "red")
    }
}
