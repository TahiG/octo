//
//  FolioHelper.swift
//  Globe
//
//  Created by Amarjit on 12/12/2016.
//  Copyright © 2016 Charles Masson. All rights reserved.
//

import Foundation

// Helper class for reading ebooks from server
class FolioHelper: NSObject {

    var book: Book!

    class func preload(book:Book, completion:(bookPath:String?, error:NSError?) -> Void)
    {
        var book:Book = book
        if book.isBookInDocs()
        {
            book.bookDir = self.getBookPath(book)
            completion(bookPath: book.bookDir, error: nil)
        } else {
            // Loading ebook from parse and saving in doc directory
            book.ebookFromParse({ (bookPath, error) in
                if (error != nil) {                    
                    completion(bookPath: nil, error: error)
                }
                else {
                    print ("FOUND EBOOK PATH - \(bookPath)\n\n")
                    completion(bookPath: bookPath, error: nil)
                }
            })
        }
    }

    // Get the book path
    private class func getBookPath(book:Book) -> String {
        _ = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0]

        let bookDir = docsDir.stringByAppendingPathComponent(book.bookId + "-book.epub")
        print("Attempting: \(bookDir)")


        return bookDir
    }
}
