# 🏡 PremiSave

<p align="center">
  <img src="https://github.com/graham218.png" width="120" alt="Project Owner" style="border-radius:50%;" />
</p>

<p align="center">
  <strong>A next-generation real estate platform for listings, rentals, sales & property management</strong><br/>
  Built for scale, performance, and a premium user experience
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-in%20development-yellow" />
  <img src="https://img.shields.io/badge/domain-real%20estate-success" />
  <img src="https://img.shields.io/badge/backend-spring%20boot-brightgreen" />
  <img src="https://img.shields.io/badge/frontend-flutter-blue" />
  <img src="https://img.shields.io/badge/database-mongodb-success" />
  <img src="https://img.shields.io/badge/cache-redis-red" />
  <img src="https://img.shields.io/badge/container-docker-2496ED" />
  <img src="https://img.shields.io/badge/orchestration-kubernetes-326CE5" />
</p>

---

## 🌍 About PremiSave

**PremiSave** is a modern, cloud-native **real estate and property management platform** designed to simplify how people **buy, sell, rent, and manage properties**.

The platform connects **property owners, agents, tenants, buyers, and administrators** through secure, role-based dashboards that improve transparency, trust, and operational efficiency.

PremiSave is built with **scalability, performance, and enterprise-grade architecture** at its core.

---

## ✨ Core Features

### 👤 User & Role Management
- Secure authentication & authorization
- Role-based access control (Admin, Agent, Owner, Tenant, Buyer)
- JWT-based security
- Profile pictures stored via **Cloudinary**

### 🏘️ Property Listings
- Residential & commercial properties
- Rentals & property sales
- Advanced search & filters (price, location, amenities)
- High-quality image galleries
- Availability & status tracking

### 📍 Location & Discovery
- Map-based property search
- Geo-search optimization
- Nearby amenities & landmarks

### 📄 Digital Documents
- Lease agreements
- Sale contracts
- Property documents
- Secure uploads using **Firebase Storage**

### 💳 Payments & Transactions
- Rent payments
- Booking & reservation fees
- Commission tracking
- Transaction history & receipts

### 📊 Dashboards & Analytics
- Admin insights & system reports
- Agent performance analytics
- Occupancy & revenue tracking

---

## 🧱 System Architecture

                ┌─────────────────────────┐
                │   Flutter App (Web &    │
                │   Mobile)               │
                └──────────▲──────────────┘
                           │ REST / JSON
            ┌──────────────┴──────────────┐
            │     API Gateway (Spring)     │
            └────────▲────────▲────────▲──┘
                     │        │        │
    ┌────────────────┴─┐ ┌────┴──────┐ ┌───────────────┐
    │ Auth Service      │ │ Property  │ │ Payment Svc  │
    │ Users & Roles     │ │ Listings  │ │ Transactions │
    └──────────────────┘ └───────────┘ └───────────────┘
              ▲                  ▲                ▲
              │                  │                │
          MongoDB             MongoDB          MongoDB
              │                  │                │
           Redis Cache (Shared Performance Layer)


---

## 🧰 Tech Stack

### Backend (Microservices)
- **Java 17**
- **Spring Boot**
- **Spring Cloud (Gateway, Config, Discovery)**
- **Spring Security + JWT**
- **MongoDB**
- **Redis**

### Frontend
- **Flutter** (Android, iOS, Web)
- Modern, responsive UI
- Mobile-first design

### Storage & Media
- **Cloudinary** – Property images & profile pictures
- **Firebase Storage** – Documents & contracts

### DevOps & Infrastructure
- **Docker** – Containerization
- **Kubernetes** – Orchestration & auto-scaling
- **NGINX / Ingress Controller**
- **CI/CD Ready** (GitHub Actions compatible)

---

## 🚀 Microservices Overview

| Service | Responsibility |
|------|----------------|
| API Gateway | Routing, security, rate limiting |
| Auth Service | Authentication & roles |
| User Service | User accounts & profiles |
| Property Service | Listings & property data |
| Booking Service | Visits & reservations |
| Payment Service | Rent & sales transactions |
| Notification Service | Email, SMS & push alerts |

---

## ⚡ Caching Strategy (Redis)

- Frequently searched properties
- User sessions & tokens
- Featured listings
- Dashboard statistics

This ensures **low latency, high throughput, and reduced database load**.

---

## 🎨 UI & UX Principles

- Clean, premium real-estate design
- Map-first property discovery
- Mobile-first experience
- Trust-driven transaction layouts

> **Great homes deserve great digital experiences.**

---

## 👨‍💻 Project Owner

**Bill Graham**  
GitHub: [@graham218](https://github.com/graham218)  
Title: *Peacemaker* ✌️

---

## 🛣️ Roadmap

- [ ] Property listings MVP
- [ ] Advanced search & maps
- [ ] Payments integration
- [ ] Booking & visit scheduling
- [ ] Digital lease signing
- [ ] AI-powered price recommendations

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository  
2. Create a feature branch  
3. Commit your changes  
4. Open a Pull Request  

---

## 📄 License

This project is licensed under the **GNU General Public License (GPL)**.

- You may use, modify, and distribute this software
- Any derivative work **must remain open-source**
- Source code disclosure is required for redistribution

---

<p align="center">
  🏡 <strong>PremiSave – Smarter living starts with smarter property management</strong>
</p>

