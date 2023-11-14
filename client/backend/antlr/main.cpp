#include <iostream>
#include <sstream>
#include <antlr4-runtime.h>
#include "CypherLexer.h"
#include "CypherParser.h"

using namespace std;
using namespace antlr4;

int main(int argc, char **argv) {
    stringstream stream(argv[1]);
    ANTLRInputStream input(stream);
    CypherLexer lexer(&input);
    CommonTokenStream tokens(&lexer);
    CypherParser parser(&tokens);
    CypherParser::OC_CypherContext* tree = parser.oC_Cypher();
    return 0;
}