

**BookSwap App – ERD Diagram (ASCII Version)**


                                 ┌──────────────────────┐
                                 │        USERS         │
                                 ├──────────────────────┤
                                 │ uid : String (PK)    │
                                 │ displayName : String │
                                 │ email : String       │
                                 │ photoUrl : String?   │
                                 │ createdAt : Timestamp│
                                 └───────────┬──────────┘
                                             │1
                                             │
                                             │has many
                                             ▼
                      ┌───────────────────────────────┐
                      │             BOOKS              │
                      ├───────────────────────────────┤
                      │ bookId : String (PK)          │
                      │ ownerId : String (FK→Users)   │
                      │ ownerName : String            │
                      │ title : String                │
                      │ author : String               │
                      │ condition : Enum              │
                      │ swapFor : String?             │
                      │ coverUrl : String             │
                      │ createdAt : Timestamp         │
                      └───────────────┬───────────────┘
                                      │1
                                      │
                                      │involved in
                                      ▼
                     ┌────────────────────────────────────┐
                     │               SWAPS                 │
                     ├────────────────────────────────────┤
                     │ swapId : String (PK)               │
                     │ bookId : String (FK→Books)         │
                     │ senderId : String (FK→Users)       │
                     │ receiverId : String (FK→Users)     │
                     │ status : "pending/accepted/rejected" │
                     │ createdAt : Timestamp              │
                     │ updatedAt : Timestamp              │
                     └───────────────┬─────────────┬──────┘
                                     │             │
                            chat created from swap │
                                     │             │
                                     ▼             ▼
                          ┌────────────────────────────┐
                          │            CHATS           │
                          ├────────────────────────────┤
                          │ chatId : String (PK)       │
                          │ participants : [uid, uid]  │
                          │ lastMessage : String       │
                          │ lastAt : Timestamp         │
                          └───────────────┬────────────┘
                                          │1
                                          │
                                          │has many
                                          ▼
                         ┌────────────────────────────────┐
                         │            MESSAGES            │
                         ├────────────────────────────────┤
                         │ messageId : String (PK)        │
                         │ senderId : String (FK→Users)   │
                         │ text : String                  │
                         │ sentAt : Timestamp             │
                         └────────────────────────────────┘
```

---

#  **Explanation of ERD Entities**

## **1. USERS**

Stores authentication-related and profile data for each user.

**Important fields:**

* `uid` — primary key, also Firebase Auth UID
* `displayName` — used when posting books
* `photoUrl` — optional profile picture
* `createdAt` — timestamp from Firestore

**Relationships:**

* One *user* can create **many books**
* One *user* can send or receive **many swap requests**
* One *user* can participate in **many chats**

---

## **2. BOOKS**

Represents a listing created by a user.

**Key fields:**

* `ownerId` — foreign key referencing USERS
* `title`, `author`, `condition` — book details
* `swapFor` — optional field describing what book they want
* `coverUrl` — stored in Firebase Storage
* `createdAt` — timestamp for sorting

**Relationships:**

* Each **book** can have **many swaps** (multiple people may attempt to swap for it)



## **3. SWAPS**

Tracks the exchange request between two users for a specific book.

**Key fields:**

* `bookId` — FK → BOOKS
* `senderId` — user who requested the swap
* `receiverId` — book owner
* `status` — `"pending"`, `"accepted"`, `"rejected"`
* `createdAt` & `updatedAt`

**Relationships:**

* Each **swap** leads to **one chat** between the two users (optional but implemented)
* Only `senderId` and `receiverId` can update/read this document
  *(secured by Firestore rules)*

---

## **4. CHATS**

Created when:

* A swap request is initiated
* OR two users previously chatted for another swap

**Fields:**

* `participants` — always two UIDs
* `lastMessage` — for showing chat preview
* `lastAt` — timestamp

**Relationships:**

* Each chat has **many messages**
* Only participants can read/write messages

---

## **5. MESSAGES**

Subcollection under each chat.

**Fields:**

* `senderId` — identifies who sent the message
* `text` — content
* `sentAt` — timestamp

Messages update the chat’s `lastMessage` and `lastAt`.

---

# 🔗 **Relationship Summary (Simple Explanation for Your Paper)**

Here’s a clean summary to include in your design document:

* **Users → Books (1-to-many)**
  Each user can create multiple book listings.

* **Books → Swaps (1-to-many)**
  Many users may initiate a swap for the same book.

* **Users → Swaps (many-to-many)**
  One user can send swaps to many users.
  One user can receive swaps from many users.

* **Swaps → Chats (1-to-1)**
  When a swap request is made, a chat is automatically created.

* **Chats → Messages (1-to-many)**
  Each chat contains a messages subcollection.

