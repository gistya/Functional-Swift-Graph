import Foundation

struct GraphTest {
    
    func run()->Void {
        
        // Demonstration
                
        var graph = Graph<String>()
        
        graph = graph.add(nodeWith:"Foo") //0
        graph = graph.add(nodeWith:"Bar") //1
        graph = graph.add(nodeWith:"Baz") //2
        graph = graph.add(nodeWith:"Bruh") //3
        graph = graph.add(nodeWith:"Freak") //4
        graph = graph.add(nodeWith:"Win")   //5
        graph = graph.add(nodeWith:"Internet") //6
        graph = graph.add(nodeWith:"Awesome") //7
        graph = graph.add(nodeWith:"Baz") //8
        graph = graph.connect(node: graph.nodes[0], to: graph.nodes[2]) 
        graph = graph.connect(node: graph.nodes[3], to: graph.nodes[2]) 
        graph = graph.connect(node: graph.nodes[3], to: graph.nodes[0]) 
        graph = graph.connect(node: graph.nodes[4], to: graph.nodes[3]) 
        graph = graph.connect(node: graph.nodes[4], to: graph.nodes[7]) 
        graph = graph.connect(node: graph.nodes[8], to: graph.nodes[1]) 
        
        printEdges(adjacentToNodeWith: "Baz", graph: graph)
        // The above should just print two edges for Node 1: 0-2 and 3-2
        // and one edge for Node 8: 8-1

        // Remove the first node and check what's left.
        
        let prunedGraph = graph.remove(node: graph.nodes[0])
        print("\n\n**** after removal: \n\n")
        print("lookup: \(prunedGraph.lookup)\n")
        
        printEdges(adjacentToNodeWith: "Baz", graph: prunedGraph) 
        // The above should print one edge for Node 1: 2-1
        // and one edge for Node 8: 7-0
        
        printEdges(adjacentToNodeWith: "Freak", graph: prunedGraph)
        // The above should print two edges: 3-6 and 3-2
        
        // Search examples from wikipedia for DFS and BFS.
        
        //BFS example:
        print("\n\n ***** BFS **** \n\n")

        graph = Graph<String>()
        graph = graph.add(nodeWith:"A") //0
        graph = graph.add(nodeWith:"B") //1
        graph = graph.add(nodeWith:"C") //2
        graph = graph.add(nodeWith:"D") //3
        graph = graph.add(nodeWith:"E") //4
        graph = graph.add(nodeWith:"F") //5
        graph = graph.add(nodeWith:"G") //6
        graph = graph.add(nodeWith:"H") //7
        graph = graph.connect(node: graph.nodes[0], to: graph.nodes[1]) 
        graph = graph.connect(node: graph.nodes[0], to: graph.nodes[2]) 
        graph = graph.connect(node: graph.nodes[1], to: graph.nodes[3]) 
        graph = graph.connect(node: graph.nodes[1], to: graph.nodes[4]) 
        graph = graph.connect(node: graph.nodes[2], to: graph.nodes[5]) 
        graph = graph.connect(node: graph.nodes[2], to: graph.nodes[6]) 
        graph = graph.connect(node: graph.nodes[4], to: graph.nodes[7])
        
        printEdges(adjacentToNodeWith: "A", graph: graph)
        // Should print for Node 0: 0-1 and 0-2
        
        let bfsGraph = graph.bfsFlatMap(source: graph.nodes[0])
        print(bfsGraph.nodes)
        //A, B, C, D, E, F, G, H is expected order of values in the output.
        
        let bfsGraph2 = graph.bfsFlatMap(source: graph.nodes[0], query:graph.nodes[3])
        print(bfsGraph2.nodes)
        //A, B, C, D is expected order of values in the output.
        
        printEdges(adjacentToNodeWith: "B", graph: bfsGraph)
        // Should print for Node 0: 0-1 and 0-2
        
        // DFS test
        print("\n\n ***** DFS **** \n\n")
        
        graph = Graph<String>()
        graph = graph.add(nodeWith:"A") //0
        graph = graph.add(nodeWith:"B") //1
        graph = graph.add(nodeWith:"C") //2
        graph = graph.add(nodeWith:"E") //3
        graph = graph.add(nodeWith:"D") //4
        graph = graph.add(nodeWith:"F") //5
        graph = graph.add(nodeWith:"G") //6
        graph = graph.connect(node: graph.nodes[0], to: graph.nodes[1]) 
        graph = graph.connect(node: graph.nodes[0], to: graph.nodes[2]) 
        graph = graph.connect(node: graph.nodes[0], to: graph.nodes[3]) 
        graph = graph.connect(node: graph.nodes[1], to: graph.nodes[4]) 
        graph = graph.connect(node: graph.nodes[1], to: graph.nodes[5]) 
        graph = graph.connect(node: graph.nodes[5], to: graph.nodes[3]) 
        graph = graph.connect(node: graph.nodes[2], to: graph.nodes[6]) 
        
        let dfsGraph = graph.dfsFlatMap(source: graph.nodes[0])
        print(dfsGraph.nodes)
        //A, B, D, F, E, C, G is the expected order of values in the output.
        
        
        let dfsGraph2 = graph.dfsFlatMap(source: graph.nodes[0], query: graph.nodes[3])
        print(dfsGraph2.nodes)
        //A, B, D, F, E is the expected order of values in the output.
    }
    
    
    func printEdges<_Content:Hashable>(adjacentToNodeWith value:_Content, graph:Graph<_Content>) {
        print("\n\nEdges adjacent to nodes with \(value):\n")
        for (id1, adjacencyPairings) in graph.edges(adjacentToNodesWith: value) {
            print("  \(value): \(id1)\n")
            for edge in adjacencyPairings {
                //print("   to: \(id2)\n")
                print("     edge:\n\(edge)")
            }
        }
        
    }
}

var test = GraphTest()

test.run()
