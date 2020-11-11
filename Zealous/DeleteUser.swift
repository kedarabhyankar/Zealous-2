//
//  DeleteUser.swift
//  Zealous
//
//  Created by Hannah Shiple on 11/11/20.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase
import SwiftUI
import Foundation
import FirebaseAnalytics
import Firebase

extension WriteableUser {
    
    
     func deleteUser(theUser: WriteableUser) {
        var followedTopics: [Topic] = []
        var createdPosts: [Post] = []
        var theUser: WriteableUser = theUser
        
        
        WriteableUser.getCreatedPosts(email: theUser.email, completion: { (postArray) in
            if postArray == nil {
                print("error getting created posts array")
            } else {
                createdPosts = postArray
            }
        })
        
        
        //1. delete the user's created posts
        for aPost in createdPosts {
            //delete from topic's post array and delete topic if post array count is zero
            Topic.getTopic(topicTitle: aPost.topic, completion: { (theTopic) in
                if theTopic == nil {
                    print("error getting the topic")
                } else {
                    var topic: Topic = theTopic
                    for post in createdPosts {
                        if (theTopic.posts.contains(post.postId)) {
                            topic.removePost(postId: post.postId)
                            if (theTopic.posts.count == 0) {
                                Topic.deleteTopic(topicName: theTopic.title)
                            }
                        }
                    }
                    if (theTopic.posts.count == 0) {
                        Topic.deleteTopic(topicName: theTopic.title)
                    }
                }
            })
            Post.deleteStoragePost(thePost: aPost, theUser: theUser)
            Post.deletePost(postId: aPost.postId)
        }
        
        //2. make the user's unfollow the user
        theUser.getFollowers(addUser: { follower in
            if (follower == nil) {
                print("error getting the follower user")
            } else {
            var aFollower: WriteableUser = follower
            aFollower.unfollow(email: theUser.email)
            }
        })
        
        //3. unfollow all the followed users
        theUser.getFollowedUsers(addUser: { followed in
            if (followed == nil) {
                print("error getting followed user")
            } else {
                theUser.unfollow(email: followed.email)
            }
        })
        
        //4. unfollow all the followed topics
        
        //5. delete everything from storage
        
        //6. delete user from firestore
        
        //7. delete user form auth
        
    }
    
    
}
