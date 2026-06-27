# Federation Lifecycle

```mermaid
flowchart TD
    D["1. Discovery"] --> E["2. Evaluation"]
    E --> N["3. Negotiation"]
    N --> ES["4. Establishment"]
    ES --> AF["5. Active Federation"]
    AF --> EV["6. Evolution"]
    EV --> AF
    EV --> S(["7. Suspension (optional)"])
    S --> AF
    S --> T["8. Termination"]
    EV --> T
    T --> HP["9. Historical Preservation"]

    classDef stage fill:#eef3fb,stroke:#33415c,stroke-width:1px;
    classDef opt fill:#fbf3e6,stroke:#8c6a2b,stroke-width:1px,stroke-dasharray:4 3;
    class D,E,N,ES,AF,EV,T,HP stage;
    class S opt;
```

*Caption: The 9-stage federation lifecycle — Discovery through Historical Preservation, with Evolution looping back to Active Federation and Suspension as an optional return path.*
