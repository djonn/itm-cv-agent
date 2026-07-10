# Project Experience

Start date (month/year): 10/2024
End date (month/year): 08/2026

Competencies:

- C#
- .NET
- React
- SignalR
- Event Sourcing
- CQRS
- Elixir
- Azure

## Client

Client name: Bunker Holding
Project name: AuctionConnect

Bunker Holding is the world's largest bunkering company and supplies marine fuel to ships across the globe. Traditionally, much of the trading takes place over phone calls and WhatsApp with a broker as an intermediary between buyers and suppliers.

AuctionConnect is an online auction platform developed to digitize and streamline bunker fuel trading. The platform is used by both Bunker Holding's own companies and competitors to conduct auctions faster and more efficiently, enabling buyers to achieve the lowest possible prices. The platform enables real-time updates and live bidding, making the process faster and more competitive.

As a result of AuctionConnect, the platform has contributed to selling more than 1 million MT (metric tons) of fuel annually. Users consistently see prices lower than the daily index, and over the past six months there has been a doubling in the number of monthly auctions. The platform typically has 10-15 buyers conducting auctions with up to 40 concurrent users logged in.

## Developer's Role

Role name: Feature Lead & Senior Software Developer

Jonas Nielsen originally worked as Feature Lead in a team consisting of 5 consultants from IT Minds and a UX designer from a sister company. As the project grew, the team evolved significantly and now includes a Product Manager, a CTO, an Engineering Manager, and 10-15 developers in Portugal. Jonas' role evolved along the way to more closely resemble a Senior Software Developer role.

Jonas took responsibility for developing a new Contract Management feature that handles long-term contracts for fueling specific fuel types in the same port at a fixed price. The feature was a strategic priority for Bunker Holding as it enables management of monthly volumes and automates communication between shipping companies and suppliers, reducing manual follow-up and ensuring more predictable revenue streams. Jonas worked primarily with backend development but touched all parts of the system during the project.

A central part of Jonas' work was leading the migration from Elixir/Phoenix/LiveView to C#/.NET and React with SignalR. Jonas and the team chose to approach the migration using a strangler pattern to minimize risk: First, LiveView pages not related to live auctions were taken over by React with REST endpoints. Then responsibility was gradually moved to .NET. Jonas designed an adapter/repository pattern for master data so the auction engine could continue accessing companies, ports, fuel types, and ships without interruptions. On the .NET side, Jonas implemented a wrapper service that calls Elixir endpoints to fetch auction state and perform mutating actions, ensuring continuity during the migration.

The platform uses event sourcing and CQRS, which provides automatic auditing of all actions in an auction - a significant advantage in the regulated bunkering industry where compliance and traceability are critical to meeting industry requirements. Jonas ensured that real-time updates from the original LiveView architecture were preserved in the new SignalR-based solution, so users could continue to follow live bidding without delays.
