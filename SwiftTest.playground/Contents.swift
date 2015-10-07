//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var count : Int

var shouldRemind : Bool

var text : String

var i = 10

var f : Float

var d = 3.14

var b = true

var s = "Hello world"

f = Float(i)

print(f)


class MyObject {
    
    var count = 7
    
    init(count:Int){
        
        self.count = count
        
    }
    
    func myMethod() {
        
        var count = 42;
        
        print(count)
        
        print(self.count)
    }
    
    class func makeObjectWithCount(count:Int) ->MyObject {
        
        let m = MyObject(count: 60)
        
        m.count = count
        
        return m
    
    }
}

var myobject = MyObject(count:50)

var c1 = myobject.count

let myInstance = MyObject.makeObjectWithCount(60).count


for i in 0...4 {
    
    print(i)
}

for var i = 0; i < 5; i += 2 {
    
    print(i)
}

