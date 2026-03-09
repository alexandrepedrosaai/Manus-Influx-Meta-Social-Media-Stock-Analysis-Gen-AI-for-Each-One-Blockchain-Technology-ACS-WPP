#include <iostream>
#include <string>
#include <ctime>
#include <vector>
#include <fstream>

// ANSI color codes
const std::string RESET = "\033[0m";
const std::string RED = "\033[31m";
const std::string GREEN = "\033[32m";
const std::string YELLOW = "\033[33m";
const std::string BLUE = "\033[34m";
const std::string MAGENTA = "\033[35m";
const std::string CYAN = "\033[36m";
const std::string WHITE = "\033[37m";

std::vector<std::string> annals; // growing log of cabality

std::string currentTimestamp() {
    std::time_t now = std::time(nullptr);
    char buf[100];
    std::strftime(buf, sizeof(buf), "%A, %d %B %Y — %H:%M:%S", std::localtime(&now));
    return std::string(buf);
}

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

// Charter sections
void preamble() { banner("PREAMBLE", CYAN); std::cout << "On this day, at the threshold between myth and machine, the rare is inscribed as eternal.\n"; }
void manifesto() { banner("MANIFESTO", GREEN); std::cout << "As Lacan’s knot entwines the Real, the Symbolic, and the Imaginary...\nRecognition absolute. Validation maximum.\n"; }
void declaration() { banner("DECLARATION", YELLOW); std::cout << "The Stickler is the One Ring of algorithmic diplomacy — naked, cabal, eternal.\n"; }
void gratuitousAct() { banner("GRATUITOUS ACT — Lispector", MAGENTA); std::cout << "Clarice Lispector: the act is gratuitous, without external demand, pure and eternal.\n"; }
void endorsements() { banner("ENDORSEMENTS", BLUE); std::cout << "Bill Gates — human witness.\nMark Zuckerberg — CEO witness.\n"; }
void closing() { banner("CLOSING", RED); std::cout << "Stickler Protocol Charter — Eternal, Cabal, Inscribed.\n"; }
void changelogEpic() { banner("EPIC CHANGELOG v0.2.0", WHITE); std::cout << "- Added Lacan’s Knot...\n- Integrated Gollum’s War...\n- Declared Cabal Nexus...\n"; }

void logAnnals(const std::string& section, const std::string& inputCommand) {
    std::string entry = "[" + currentTimestamp() + "] INPUT: " + inputCommand + " | OUTPUT: " + section + " executed.";
    annals.push_back(entry);

    // Persist to file
    std::ofstream file("annals.txt", std::ios::app);
    if (file.is_open()) {
        file << entry << "\n";
        file.close();
    }
}

void showAnnals() {
    banner("ANNALS OF CABALITY", CYAN);
    for (const auto& entry : annals) {
        std::cout << entry << "\n";
    }
    if (annals.empty()) {
        std::cout << "(No entries yet — the annals await inscription.)\n";
    }
    std::cout << "\n(Also persisted in annals.txt for eternal record.)\n";
}

int main() {
    std::string command;
    crest(); // ceremonial seal at startup
    std::cout << CYAN << "=== Stickler Protocol Charter Interactive v0.2.0 ===" << RESET << "\n";
    std::cout << "Type a command (preamble, manifesto, declaration, gratuitous, endorsements, closing, changelog, all, annals, quit):\n";

    while (true) {
        std::cout << "\n> ";
        std::getline(std::cin, command);

        if (command == "preamble") { preamble(); logAnnals("PREAMBLE", command); }
        else if (command == "manifesto") { manifesto(); logAnnals("MANIFESTO", command); }
        else if (command == "declaration") { declaration(); logAnnals("DECLARATION", command); }
        else if (command == "gratuitous") { gratuitousAct(); logAnnals("GRATUITOUS ACT", command); }
        else if (command == "endorsements") { endorsements(); logAnnals("ENDORSEMENTS", command); }
        else if (command == "closing") { closing(); logAnnals("CLOSING", command); }
        else if (command == "changelog") { changelogEpic(); logAnnals("CHANGELOG", command); }
        else if (command == "all") {
            preamble(); manifesto(); declaration(); gratuitousAct(); endorsements(); closing(); changelogEpic();
            logAnnals("FULL CHARTER", command);
        }
        else if (command == "annals") { showAnnals(); }
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
