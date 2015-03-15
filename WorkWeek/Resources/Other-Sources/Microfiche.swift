//
//  Microfiche.swift
//  Microfiche is an set of functions usable in Swift for
//  archiving Array<T>, Set<T>, and Dictionary<T,U>
//
//  Created by John Regner on 3/13/15.
//

import Foundation

/** 
*   Pass in your Swift Collection before Archiving. This function returns an object
*   which is suitable for NSKeyedArchiving
*
*   Convert input Collection<T> into an NSMutableArray<NSData>
*   works with Array<T>, Set<T>, Dictionary<T,U>
*/
public
func convertCollectionToArrayOfData<T: CollectionType>(collection: T) -> NSMutableArray {
    return NSMutableArray(array: map(collection){
        var mutableItem = $0
        return NSData(bytes: &mutableItem, length: sizeof(T.Generator.Element.self))
        })
}

/**
*/
public
func restoreArrayFromArchiveArray<T>( array: NSMutableArray) -> Array<T>{
    return Array<T>( map( array ) { memoryOfType(fromAnyObject: $0) } )
}

/**
*/
public
func restoreDictFromArchiveArray<T,U>(array: NSMutableArray) -> Dictionary<T,U>{
    var results = Dictionary<T,U>()
    map(array){ item -> Void in
        let (k,v): (T,U)  = memoryOfType(fromAnyObject: item)
        results[k] = v
    }
    return results
}

/**
* This is a helper function. You probably should not be calling this
*
* But if you do want to call it, pleas not that the Type T
* which all the sizes and Pointer types use is inferred from the return type
* You may need to explicitly declare a return type when using this. 
* see `restoreDictFromArchiveArray` for an example
*/

private
func memoryOfType<T>(fromAnyObject obj: AnyObject) -> T {
    let mutableData = obj as NSData
    var itemData = UnsafeMutablePointer<T>.alloc(sizeof(T))
    mutableData.getBytes(itemData, length: sizeof(T))
    return itemData.memory
}
