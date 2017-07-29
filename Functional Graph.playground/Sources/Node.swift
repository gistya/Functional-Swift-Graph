import Foundation

public struct Node<_Content:Hashable>:Hashable {
    public var createdTime: Date = Date()
    public var id: Id
    public var value: _Content
    public static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.createdTime == rhs.createdTime && lhs.value == rhs.value
    }
    public init(id:Id, value:_Content) {
        self.id = id
        self.value = value
    }
    public var hashValue: Int {
        get {
            return Int(createdTime.timeIntervalSince1970)
        }
    }
}

extension Node: CustomStringConvertible {
    public var description:String {
        get {
            return "Id: \(id), Value: \(value)"
        }
    }
}
