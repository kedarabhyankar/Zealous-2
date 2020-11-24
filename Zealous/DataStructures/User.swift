//
//  User.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

extension WriteableUser {
    
    mutating func addLikedPost(post: Post) {
        self.likedPosts.append(post.postId)
    }
    
    mutating func deleteLikedPost(postId: String) {
        let index: Int = self.likedPosts.firstIndex(of: postId)!
        self.likedPosts.remove(at: index)
    }
    
    mutating func addDislikedPost(post: Post) {
        self.dislikePosts.append(post.postId)
    }
    
    mutating func deleteDislikedPost(postId: String) {
        let index: Int = self.dislikePosts.firstIndex(of: postId)!
        self.dislikePosts.remove(at: index)
    }
    mutating func addSavedPost(post: Post) {
        self.savedPosts.append(post.postId)
    }
    
    mutating func deleteSavedPost(postId: String) {
        let index: Int = self.savedPosts.firstIndex(of: postId)!
        self.savedPosts.remove(at: index)
    }
    
    mutating func addCreatedPost(post: Post) {
        self.createdPosts.append(post.postId)
    }
    
    mutating func deleteCreatedPost(postId: String) {
        let index: Int = self.createdPosts.firstIndex(of: postId)!
        self.createdPosts.remove(at: index)
    }
    
    func getFollowedTopics(addTopic: @escaping((Topic) -> ())) {
        let db = Firestore.firestore()
        for topicTitle in self.interests {
            // get the post and convert to Post object
            let ref = db.collection("topics")
            
            ref.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                }
                else {
                    db.collection("topics")
                        .whereField("title", isEqualTo: topicTitle)
                        .getDocuments() { (QuerySnapshot, err) in
                            
                            if QuerySnapshot?.isEmpty == true {
                                
                                //topic does not exist, so create a new topic in database and topic object
                                
                                print("Topic does not exist")
                                //create a topic object and add current post to its post array
                                let newTopic = Topic.init(title: topicTitle)
                                
                                
                                let dataToWrite1 = try! FirestoreEncoder().encode(newTopic)
                                db.collection("topics").document(newTopic.title).setData(dataToWrite1) { error in
                                    if (error != nil) {
                                        print("error writing topic to firestore: \(String(describing: error))")
                                        return
                                    } else {
                                        print("success writing topic to firestore")
                                    }
                                }
                                
                                let docRef = Firestore.firestore().collection("topics").document(topicTitle)
                                docRef.getDocument { document, error in
                                    if let document = document {
                                        if document.data() == nil {
                                            print("Topic does not exist")
                                            return
                                        }
                                        let model = try! FirestoreDecoder().decode(Topic.self, from: document.data()!)
                                        // call function to add topic to array
                                        addTopic(model)
                                    } else {
                                        print("Document does not exist")
                                    }
                                }
                            }
                            else {
                                let docRef = Firestore.firestore().collection("topics").document(topicTitle)
                                docRef.getDocument { document, error in
                                    if let document = document {
                                        if document.data() == nil {
                                            print("Topic does not exist")
                                            return
                                        }
                                        let model = try! FirestoreDecoder().decode(Topic.self, from: document.data()!)
                                        // call function to add topic to array
                                        addTopic(model)
                                    } else {
                                        print("Document does not exist")
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func getFollowedUsers(addUser: @escaping((WriteableUser) -> ())) {
        let db = Firestore.firestore()
        for id in self.followedUsers {
            // get the user and convert to Post object
            let ref = db.collection("users").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                    //print("Model: \(model)")
                    addUser(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func getFollowers(addUser: @escaping((WriteableUser) -> ())){
        let db = Firestore.firestore()
        for id in self.followers {
            // get the post and convert to Post object
            let ref = db.collection("users").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                    //print("Model: \(model)")
                    addUser(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    static func getCreatedPosts(email: String, completion: @escaping(([Post]) -> ())) {
        let db = Firestore.firestore()
        db.collection("posts").whereField("creatorId", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var createdPosts: [Post] = []
                    for document in querySnapshot!.documents {
                        let model = try! FirestoreDecoder().decode(Post.self, from: document.data())
                        createdPosts.append(model)
                        print("\(document.documentID) => \(document.data())")
                    }
                    completion(createdPosts)
                }
            }
    }
    
    func getLikedPosts(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for id in self.likedPosts {
            // get the post and convert to Post object
            let ref = db.collection("posts").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    if document.data() != nil {
                        let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                        addPost(model)
                    }
                    else {
                        print("Document does not exist or has been deleted")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    func getDislikePosts(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for id in self.dislikePosts {
            let ref = db.collection("posts").document(id)
            ref.getDocument { document, error in
                if document?.data() != nil {
                    let model = try! FirestoreDecoder().decode(Post.self, from: (document?.data()!)!)
                    addPost(model)
                } else {
                    print("Document does not exist")
                }
                
            }
            
        }
    }
    func getSavedPosts(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for postId in self.savedPosts {
            let ref = db.collection("posts").document(postId)
            ref.getDocument { document, error in
                if document?.data() != nil {
                    let model = try! FirestoreDecoder().decode(Post.self, from: (document?.data())!)
                    addPost(model)
                } else {
                    print("Error getting saved posts")
                }
            }
        }
    }
    
    
    func getProfilePosts(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for id in self.createdPosts {
            // get the post and convert to Post object
            let ref = db.collection("posts").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                    //print("Model: \(model)")
                    addPost(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    static func getCurrentUser(completion: @escaping((WriteableUser) -> ())) {
        let auth = Auth.auth()
        let user = auth.currentUser
        guard let email = user?.email else {
            // error
            print("user email is nil")
            fatalError()
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        userRef.getDocument { document, error in
            if let document = document {
                let model = try? FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                
                guard model != nil else {
                    print("there is no database object for this user")
                    fatalError()
                }
                
                //print("Model: \(model)")
                completion(model!)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    static func getAUser(theUser: WriteableUser, completion: @escaping((WriteableUser) -> ())) {
            let email = theUser.email
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(email)
            userRef.getDocument { document, error in
                if let document = document {
                    let model = try? FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                    guard model != nil else {
                        print("Could not find user in database")
                        fatalError()
                    }
                    completion(model!)
                } else {
                    print("User does not exist")
                }
            }
        }
    
    
    func showAndFocus(banner : Banner){
        banner.show(duration: 3)
    }
    
    mutating func addUpVote (postTitle: String) {
        // Error Banners
        let alreadyLike = Banner(title: "Upvote Removed", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLike.dismissesOnTap = true
        let db = Firestore.firestore()
        
        
        //Already Liked
        if self.likedPosts.contains(postTitle) {
            for i in 0..<self.likedPosts.count {
                if self.likedPosts[i] == postTitle {
                    self.likedPosts.remove(at: i)
                    break
                }
            }
                let dataToWrite = try! FirestoreEncoder().encode(self)
                db.collection("users").document(self.email).setData(dataToWrite) { error in
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("Upvote Removed~~~~~")
                    }
                }
            print("you already liked this post")
            self.showAndFocus(banner: alreadyLike)
            return
        }
        //Already Disliked
        if self.dislikePosts.contains(postTitle){
            for i in 0..<self.dislikePosts.count {
                if self.dislikePosts[i] == postTitle {
                    self.dislikePosts.remove(at: i)
                    break
                }
            }
                let dataToWrite = try! FirestoreEncoder().encode(self)
                db.collection("users").document(self.email).setData(dataToWrite) { error in
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
        }
        self.likedPosts.append(postTitle)
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    
    mutating func addDownVote (postTitle: String) {
        // Error Banners
        let alreadyLike = Banner(title: "Downvote Removed", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLike.dismissesOnTap = true
        
        let db = Firestore.firestore()
        let userRef = db.collection("posts").document(postTitle)
        //Already Disliked
        if self.dislikePosts.contains(postTitle) {
            for i in 0..<self.dislikePosts.count {
                if self.dislikePosts[i] == postTitle {
                    self.dislikePosts.remove(at: i)
                    break
                }
            }
            let dataToWrite = try! FirestoreEncoder().encode(self)
            db.collection("users").document(self.email).setData(dataToWrite) { error in
                if(error != nil){
                    print("error happened when writing to firestore!")
                    print("described error as \(error!.localizedDescription)")
                    return
                } else {
                    print("successfully wrote document to firestore with document id )")
                }
            }
            print("you already liked this post")
            self.showAndFocus(banner: alreadyLike)
            return
        }
        //Already Liked
        if self.likedPosts.contains(postTitle) {
            for i in 0..<self.likedPosts.count {
                if self.likedPosts[i] == postTitle {
                    self.likedPosts.remove(at: i)
                    let dataToWrite = try! FirestoreEncoder().encode(self)
                    db.collection("users").document(self.email).setData(dataToWrite) { error in
                        if(error != nil){
                            print("error happened when writing to firestore!")
                            print("described error as \(error!.localizedDescription)")
                            return
                        } else {
                            print("successfully wrote document to firestore with document id )")
                        }
                    }
                    break
                }
            }
        }
        self.dislikePosts.append(postTitle)
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    
    mutating func toggleSavedPost (postTitle: String) {
        // Error Banners
        let alreadyLike = Banner(title: "Saved Post Removed", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLike.dismissesOnTap = true
        
        let db = Firestore.firestore()
        
        //Double-Click
        if self.savedPosts.contains(postTitle) {
           for i in 0..<self.savedPosts.count {
                if self.savedPosts[i] == postTitle {
                    self.savedPosts.remove(at: i)
                    break
                }
            }
            let dataToWrite = try! FirestoreEncoder().encode(self)
            db.collection("users").document(self.email).setData(dataToWrite) { error in
                if(error != nil){
                    print("error happened when writing to firestore!")
                    print("described error as \(error!.localizedDescription)")
                    return
                } else {
                    print("successfully wrote document to firestore with document id )")
                }
            }
            print("you already saved this post")
            self.showAndFocus(banner: alreadyLike)
            return
        }
        
        self.savedPosts.append(postTitle)
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    /*
    mutating func removeSavedPost (postTitle: String) {
        // Error Banners
        let alreadyLike = Banner(title: "You already saved this post.", subtitle: "Choose a different post to save.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLike.dismissesOnTap = true
        
        let db = Firestore.firestore()
        
        if !self.savedPosts.contains(postTitle) {
            print("you did not save this post")
            self.showAndFocus(banner: alreadyLike)
            return
        }
        
        for i in 0..<self.savedPosts.count {
            if self.savedPosts[i] == postTitle {
                self.savedPosts.remove(at: i)
                break
            }
        }
        
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    */
    mutating func follow (email: String) {
        // Error Banners
        let followSelf = Banner(title: "You can't follow yourself.", subtitle: "Choose a different user to follow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        followSelf.dismissesOnTap = true
        
        let alreadyFollow = Banner(title: "You are already following this user.", subtitle: "Choose a different user to follow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyFollow.dismissesOnTap = true
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        // append user to followedUsers then write data to firestore
        if (self.email == email) {
            print("you can't follow yourself")
            self.showAndFocus(banner: followSelf)
            return
        }
        
        if self.followedUsers.contains(email) {
            print("you already follow this user")
            self.showAndFocus(banner: alreadyFollow)
            return
        }
        self.followedUsers.append(email)
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
        
        // get the user that was followed and update the followers array, then write the user
        // to the db
        let thisEmail = self.email
        
        userRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(model)")
                model.followers.append(thisEmail)
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                db.collection("users").document(email).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    mutating func unfollow (email: String) {
        // Error Banners
        let unfollowSelf = Banner(title: "You can't unfollow yourself.", subtitle: "Choose a different user to unfollow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        unfollowSelf.dismissesOnTap = true
        
        let unfollowUser = Banner(title: "You can't unfollow this user.", subtitle: "Choose a different user that you already follow to unfollow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        unfollowUser.dismissesOnTap = true
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        // append user to followedUsers then write data to firestore
        if (self.email == email) {
            self.showAndFocus(banner: unfollowSelf)
            print("you can't unfollow yourself")
            return
        }
        if !self.followedUsers.contains(email) {
            self.showAndFocus(banner: unfollowUser)
            print("you are not following this user")
            return
        }
        // delete user from following array
        for i in 0..<self.followedUsers.count {
            if self.followedUsers[i] == email {
                self.followedUsers.remove(at: i)
                break
            }
        }
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
        
        // update the followers array, then write the user
        // to the db
        let thisEmail = self.email
        
        userRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(model)")
                for i in 0..<model.followers.count {
                    if model.followers[i] == thisEmail {
                        model.followers.remove(at: i)
                        break
                    }
                }
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                db.collection("users").document(email).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func createPost (post: Post) {
        let db = Firestore.firestore()
        let dataToWrite2 = try! FirestoreEncoder().encode(post)
        db.collection("posts").document(post.postId).setData(dataToWrite2) { error in
            
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    
    func deletePost (post: Post) {
        
    }
    
    func message (msg: String) {
        
    }
    
    func block (email: String) {
        // add user to current user's blockedusers array
        // add currentuser to blockedby array
        let thisEmail = self.email
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        userRef.getDocument { document, error in
            if let document = document {
                var userToBlock = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(userToBlock)")
                for i in 0..<userToBlock.followers.count {
                    if userToBlock.followers[i] == thisEmail {
                        userToBlock.followers.remove(at: i)
                        break
                    }
                }
                userToBlock.blockedBy.append(thisEmail)
                userToBlock.unfollow(email: thisEmail)
                
                let dataToWrite2 = try! FirestoreEncoder().encode(userToBlock)
                db.collection("users").document(email).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
        
        let userRef2 = db.collection("users").document(thisEmail)
        userRef2.getDocument { document, error in
            if let document = document {
                var blocker = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(blocker)")
                blocker.blocked.append(email)
                
                let dataToWrite2 = try! FirestoreEncoder().encode(blocker)
                db.collection("users").document(thisEmail).setData(dataToWrite2) { error in
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    mutating func unblock(email: String) {
        let thisEmail = self.email
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        userRef.getDocument { document, error in
            if let document = document {
                var userToUnblock = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(userToUnblock)")
                for i in 0..<userToUnblock.blockedBy.count {
                    if userToUnblock.blockedBy[i] == thisEmail {
                        userToUnblock.blockedBy.remove(at: i)
                        break
                    }
                }
                
                let dataToWrite2 = try! FirestoreEncoder().encode(userToUnblock)
                db.collection("users").document(email).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
        
        let userRef2 = db.collection("users").document(thisEmail)
        userRef2.getDocument { document, error in
            if let document = document {
                var blocker = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(blocker)")
                for i in 0..<blocker.blocked.count {
                    if blocker.blocked[i] == email {
                        blocker.blocked.remove(at: i)
                        break
                    }
                }
                
                let dataToWrite2 = try! FirestoreEncoder().encode(blocker)
                db.collection("users").document(thisEmail).setData(dataToWrite2) { error in
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getAllTopics(allTopics: @escaping(([Topic]) -> ())) {
        //get all the topics in the database
        let db = Firestore.firestore()
        db.collection("topics").getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("error getting all topics from firestore")
            }
            else {
                var allTopicsArray: [Topic] = []
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(Topic.self, from: document.data())
                    //print("topic model: \(model)")
                    allTopicsArray.append(model)
                }
                allTopics(allTopicsArray)
            }
        }
    }
    
    func getAllUsers(allUsers: @escaping(([WriteableUser]) -> ())) {
        //get all the topics in the database
        let db = Firestore.firestore()
        db.collection("users").getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("error getting all users from firestore")
            }
            else {
                var allUsersArray: [WriteableUser] = []
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data())
                    //print("user model: \(model)")
                    allUsersArray.append(model)
                }
                allUsers(allUsersArray)
            }
        }
    }
    
    static func getAllUsersAdmin(allUsers: @escaping(([WriteableUser]) -> ())) {
        //get all the topics in the database
        let db = Firestore.firestore()
        db.collection("users").getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("error getting all users from firestore")
            }
            else {
                var allUsersArray: [WriteableUser] = []
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data())
                    //print("user model: \(model)")
                    allUsersArray.append(model)
                }
                allUsers(allUsersArray)
            }
        }
    }
    static func getAllTopicsAdmin(allTopics: @escaping(([Topic]) -> ())) {
        //get all the topics in the database
        let db = Firestore.firestore()
        db.collection("topics").getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("error getting all topics from firestore")
            }
            else {
                var allTopicsArray: [Topic] = []
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(Topic.self, from: document.data())
                    //print("topic model: \(model)")
                    allTopicsArray.append(model)
                }
                allTopics(allTopicsArray)
            }
        }
    }
    mutating func followTopic (title: String) {
        // Error Banners
        let alreadyFollow = Banner(title: "You are already following this topic.", subtitle: "Choose a different topic to follow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyFollow.dismissesOnTap = true
        
        let db = Firestore.firestore()
        let topicRef = db.collection("topics").document(title)
        
        // append then write data to firestore
        
        if self.interests.contains(title) {
            print("you already follow this user")
            self.showAndFocus(banner: alreadyFollow)
            return
        }
        self.interests.append(title)
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
        
        // get the topic that was followed and update the followers array, then write the topic
        // to the db
        let thisEmail = self.email
        
        topicRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(Topic.self, from: document.data()!)
                print("Model: \(model)")
                model.followers.append(thisEmail)
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                db.collection("topics").document(title).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    mutating func unfollowTopic (title: String) {
        // Error Banners
        
        let unfollowTopics = Banner(title: "You can't unfollow this topic.", subtitle: "Choose a different topic that you already follow to unfollow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        unfollowTopics.dismissesOnTap = true
        
        let db = Firestore.firestore()
        let topicRef = db.collection("topics").document(title)
        
        if !self.interests.contains(title) {
            self.showAndFocus(banner: unfollowTopics)
            print("you are not following this topic")
            return
        }
        // delete user from following array
        for i in 0..<self.interests.count {
            if self.interests[i] == title {
                self.interests.remove(at: i)
                break
            }
        }
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
        
        // update the followers array
        let thisEmail = self.email
        
        topicRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(Topic.self, from: document.data()!)
                print("Model: \(model)")
                for i in 0..<model.followers.count {
                    if model.followers[i] == thisEmail {
                        model.followers.remove(at: i)
                        break
                    }
                }
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                db.collection("topics").document(title).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func comment(comment: String, postId: String) {
        let publishedComment = "\(self.username): \(comment)"
        let db = Firestore.firestore()
        let posts = db.collection("posts")
        let users = db.collection("users")
        
        let userRef = users.document(self.username)
        let postRef = posts.document(postId)
        
        postRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                print("Model: \(model)")
                // add the comment
                model.comments.append(publishedComment)
                
                // push to db
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                postRef.setData(dataToWrite2) { error in
                    
                    if error != nil {
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
