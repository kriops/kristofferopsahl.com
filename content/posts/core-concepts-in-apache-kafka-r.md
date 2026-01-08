---
title: "Core Concepts in Apache Kafka®"
date: 2025-03-06T12:24:04.000Z
draft: false
tags: ["Kafka"]
showToc: true
cover:
  image: "/images/covers/kafka-icon.png"
  alt: "Core Concepts in Apache Kafka®"
---

This post is intented to give a high-level description of the basic components of [Apache Kafka](https://kafka.apache.org/)® (Kafka) for someone that is entirely new to it, and that is sufficient to get building. For significantly more detail and nuance, refer to the [official documentation](https://kafka.apache.org/documentation/).

## Records
**Records** are the fundamental units of data in Kafka. They describe the idea that something happened, i.e. **events**, and are immutable data structures containing some combination of data and metadata.

A record **key** denotes a grouping of records; records with the same key will have their order preserved by kafka. Records with different keys may not. A record **value** is the business data of a record. Both keys and values are, strictly speaking, optional. 

> 💡 The purpose of Kafka is largely the handling of records that describe events. The records are passed around, transformed (not modified), and finally used to inform side-effects.

## Topics and Partitions
**Topics** are partially ordered sets of records, consisting of **partitions** which are totally ordered sets of records. Partitions allow parallellism and can be freely added, but not non-destructively removed from a topic. Records in a topic are allocated to partitions based on hashing their keys, meaning all records with identical keys will appear in-order on a single partition. The partition **head** corresponds to its end, and the **tail** corresponds to its beginning.

A record is uniquely identified by its **partition number** and **offset**. In other words, *a record key does not identify a record*. The partition number identifies a partition within a topic, and the offset identifies a location within a partition.

## Producers and Consumers
A **producer** publishes (appends) events to at least one topic. A **consumer** reads events from at least zero topics. A single entity can be both a producer and a consumer on the same or different topics. Neither producers nor consumers can change or remove records on a topic.

## Consumer Groups and Offsets
**Consumer groups** are sets of consumers used for load-balancing. A consumer group is assigned to a topic, and exactly one consumer within the group is assigned to every partition within that topic. There can be more or less consumers in a consumer group than partitions in a topic. Consumers can be arbitrarily added to- and removed from consumer groups with little consequence.

The **low-water mark** and the **high-water mark** are particular offsets in a partition that inform a consumer group which parts of a partition that are available for consumption.

Consumers will **commit offsets** upon consuming a (batch of) record(s), i.e. *declare to the cluster that every record up to (not including) the commited offset on a partition has been consumed*. In the event that the consumer is replaced the new consumer will know where to pick up. Different strategies for commits will yield different guarantees, e.g. *at least once* or *at most once*.

## Brokers and KRaft
A deployment of Kafka consists of **broker nodes** organized in a **cluster**. The primary function of a broker node is to host partitions. Exactly one broker in every cluster gets appointed to **controller**, which is responsible for e.g., topic and partition management, and consumer-partition assignments. Consumers and producers are external to the Kafka deployment itself. 

**KRaft** (Apache Kafka Raft) is the consensus algorithm used to coordinate responsibilities between different brokers n a cluster.

> 💡 Previously the role of KRaft was fulfilled by **ZooKeeper**, which required a separate deployment, but this is no longer the case. You can still use ZooKeeper, but it has been deprecated for use with Kafka, and KRaft simultaneously provides simpler usage and better performance.

## Summary
This is very much a crude overview, and while I believe it suffices as a starting point, I would recommend everyone read the [official documentation](https://kafka.apache.org/documentation/) at some point.
