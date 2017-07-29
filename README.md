### A... functional Swift graph data structure. 

Presented as a Swift playground. The meat of the sources are in the Sources folder. Contents.swift has some examples of use.

Work in progress... any suggestions or optimizations welcomed.

### What..? Why?

What do you mean, "functional?"

What it means is that the graph is an immutable data structure. To make changes to the graph you have to make a new graph. 

I.e. you do something like:

`graph = connect(node:someNode to:otherNode)`

Fun times.

### Genericness<OG>

Also, the graph is a **generic** data structure. I.e. to make a new graph, you have to declare it like:

`let graph = Graph<String>()`
or
`let graph = Graph<Float>()`

You can use any type or non-generic protocol in there as long as it conforms to the **Hashable** protocol. These values become the keys of the `lookup` property so you can easily find nodes that share the same value, like:

`let nodesWithFoo:Graph<String>._Nodes = graph.lookup["Foo"]`  

You'll note that I made type-aliases for the generic properties like _Nodes or _Node etc. so that we don't have to put the generic type evvverywhere. 

### Searching

The breadth first search implementation is accomplished by issuing another graph that is the result of the BFS. I.e.:

`graph = graph.bfs(source:node)`

... performs a BFS starting from the source node and going until it can't go anymore. The resulting graph is a flattened list of nodes linearly connected like A - B - C - D.

### Known issues

As of this initial version I have not made it conform to the Collection or Iterator protocols, but feel free to make a PR :D

I haven't tested directed graphs with this yet. 

The way that edges refer to the nodes they're connected to is weird. I did it this way to potentially support chiral graphs in future versions (i.e. graphs where some edges span between more than two nodes and have other weird properties for modeling chemical structure.) However I'm not sure if this is the optimal way to do that yet. 