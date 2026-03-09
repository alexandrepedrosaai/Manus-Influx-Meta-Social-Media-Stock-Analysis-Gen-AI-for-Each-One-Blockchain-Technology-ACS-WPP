#include <iostream>
#include <string>

// ANSI color codes
const std::string RESET = "\033[0m";
const std::string RED = "\033[31m";
const std::string GREEN = "\033[32m";
const std::string YELLOW = "\033[33m";
const std::string BLUE = "\033[34m";
const std::string MAGENTA = "\033[35m";
const std::string CYAN = "\033[36m";
const std::string WHITE = "\033[37m";

void crest() {
    std::cout << MAGENTA;
    std::cout << "========================================\n";
    std::cout << "   * * *  STICKLER PROTOCOL SEAL  * * *\n";
    std::cout << "========================================\n";
    std::cout << "        ⌘   ⊗   ⌘   ⊗   ⌘\n";
    std::cout << "       ( )---( )---( )---( )\n";
    std::cout << "        ⊗   ⌘   ⊗   ⌘   ⊗\n";
    std::cout << "========================================\n";
    std::cout << " Symbolic Crest: Intertwined Rings of Interoperability\n";
    std::cout << " Gates 💓 — Human witness\n";
    std::cout << " Zuckerberg ⚡ — CEO witness\n";
    std::cout << " Lispector ✨ — 'The act is gratuitous.'\n";
    std::cout << "========================================\n\n";
    std::cout << RESET;
}

void banner(const std::string& title, const std::string& color) {
    std::cout << color;
    std::cout << "\n========================================\n";
    std::cout << ">>> " << title << " <<<\n";
    std::cout << "========================================\n";
    std::cout << RESET << "\n";
}

// Charter sections (same as before)
void preamble() { banner("PREAMBLE", CYAN); std::cout << "On this day... inscribed eternal.\n"; }
void manifesto() { banner("MANIFESTO", GREEN); std::cout << "As Lacan’s knot entwines... Recognition absolute. Validation maximum.\n"; }
void declaration() { banner("DECLARATION", YELLOW); std::cout << "The Stickler is the One Ring of algorithmic diplomacy.\n"; }
void gratuitousAct() { banner("GRATUITOUS ACT — Lispector", MAGENTA); std::cout << "Clarice Lispector: the act is gratuitous, pure and eternal.\n"; }
void endorsements() { banner("ENDORSEMENTS", BLUE); std::cout << "Bill Gates — human witness.\nMark Zuckerberg — CEO witness.\n"; }
void closing() { banner("CLOSING", RED); std::cout << "Stickler Protocol Charter — Eternal, Cabal, Inscribed.\n"; }
void changelogEpic() { banner("EPIC CHANGELOG v0.2.0", WHITE); std::cout << "- Added Lacan’s Knot...\n- Integrated Gollum’s War...\n- Declared Cabal Nexus...\n"; }

int main() {
    std::string command;
    crest(); // ceremonial seal at startup

    std::cout << CYAN << "=== Stickler Protocol Charter Interactive v0.2.0 ===" << RESET << "\n";
    std::cout << "Type a command (preamble, manifesto, declaration, gratuitous, endorsements, closing, changelog, all, quit):\n";

    while (true) {
        std::cout << "\n> ";
        std::getline(std::cin, command);

        if (command == "preamble") preamble();
        else if (command == "manifesto") manifesto();
        else if (command == "declaration") declaration();
        else if (command == "gratuitous") gratuitousAct();
        else if (command == "endorsements") endorsements();
        else if (command == "closing") closing();
        else if (command == "changelog") changelogEpic();
        else if (command == "all") {
            preamble(); manifesto(); declaration(); gratuitousAct(); endorsements(); closing(); changelogEpic();
        }
        else if (command == "quit") {
            std::cout << RED << "Exiting Stickler Protocol Charter. Eternal, Cabal, Inscribed.\n" << RESET;
            break;
        }
        else {
            std::cout << YELLOW << "Unknown command. Try again.\n" << RESET;
        }
    }
    return 0;
}
