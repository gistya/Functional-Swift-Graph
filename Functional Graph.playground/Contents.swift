import Foundation

struct GraphTest {
    
    func run()->Void {
        var graph = Graph<String>()
        
        graph = graph.add(nodeWith:"Foo") //0
        graph = graph.add(nodeWith:"Bar") //1
        graph = graph.add(nodeWith:"Baz") //2
        graph = graph.add(nodeWith:"Bruh") //3
        graph = graph.add(nodeWith:"Freak") //4
        graph = graph.add(nodeWith:"Win")   //5
        graph = graph.add(nodeWith:"Internet") //6
        graph = graph.add(nodeWith:"Awesome") //7
        graph = graph.connect(node1: graph.nodes[0], to: graph.nodes[2]) 
        graph = graph.connect(node1: graph.nodes[3], to: graph.nodes[2]) 
        graph = graph.connect(node1: graph.nodes[3], to: graph.nodes[0]) 
        graph = graph.connect(node1: graph.nodes[4], to: graph.nodes[3]) 
        graph = graph.connect(node1: graph.nodes[4], to: graph.nodes[7]) 
        
        printEdges(adjacentTo: 0,graph:graph)
        
        print("\n\n***** removing ***** \n\n")
        
        graph = graph.remove(node: graph.nodes[0])
        
        print("after removal: ")
        printEdges(adjacentTo: 0,graph:graph)
        print("\n\n")
        
        print("lookup: \(graph.lookup)\n")
        
        printEdges(adjacentToNodeWith: "Baz", graph: graph)
        
        graph = graph.bfs(source: graph.nodes[0])
        print(graph.nodes)
    }
    
    
    func printEdges<_Content:Hashable>(adjacentToNodeWith value:_Content, graph:Graph<_Content>) {
        print("Edges adjacent to nodes with \(value):\n")
        for (id1, adjacencyPairings) in graph.edges(adjacentToNodesWith: value) {
            print("  from: \(id1)\n")
            for (id2, edge) in adjacencyPairings {
                print("   to: \(id2)\n")
                print("     edge:\n\(edge)")
            }
        }
        
    }
    
    func printEdges<_Content:Hashable>(adjacentTo nodeId:Id, graph:Graph<_Content>) {
        guard let adjacentEdges = graph.edges(adjacentTo: nodeId) else {
            print("No adjacent edges for nodeId \(nodeId).\n")
            return
        }
        if adjacentEdges.count == 0 {
            print("No adjacent edges for nodeId \(nodeId).\n")
        }
        for edge in adjacentEdges.values {
            for connection in edge.directory {
                print("connection: \(connection)")
            }
            print("")
        }
    }
}

var test = GraphTest()

test.run()
