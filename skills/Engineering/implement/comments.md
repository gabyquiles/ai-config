# Comments

Write comments as a separate phase, after tests pass and refactoring is done.
Good comments capture what the code _can't_ say: the contract callers depend on,
and the intent behind non-obvious logic.

## Two Kinds of Comments

### Interface comments

Document what a module, function, or class does and the contract it offers, so a
caller can use it **without reading the body**. This complements
[deep-modules.md](deep-modules.md): a deep module's small interface deserves a
clear description of the abstraction it hides.

Cover the things a caller must know but can't see from the signature:

- What it does (one level above the implementation)
- Preconditions, side effects, and what it returns
- Errors/exceptions it can raise
- Units, ranges, ownership, or thread-safety where relevant

### Implementation comments

Explain _why_ the code does something non-obvious - edge cases, invariants,
workarounds, or a decision that would otherwise look wrong. The reader can see
_what_ the code does; tell them _why_.

## The Different-Abstraction Rule

A comment must operate at a **different abstraction level than the code**. If the
comment restates the code, it adds nothing and rots the moment the code changes.

```typescript
// BAD: same abstraction as the code - just restates it
// increment i by 1
i += 1;

// BAD: restates the mechanics
// loop over users and call save on each
for (const u of users) u.save();
```

```typescript
// GOOD: higher abstraction - explains the intent
// Retry the whole batch so a mid-flush crash can't leave users half-saved.
for (const u of users) u.save();
```

## Comment Where Intent Isn't Clear

Don't comment the obvious; do comment the surprising.

```typescript
// BAD: obvious from the code
// return the total
return total;

// GOOD: explains a non-obvious workaround
// Stripe rounds half-to-even, so we pre-round here to match their totals
// and avoid a 1-cent reconciliation drift.
const amount = roundHalfEven(total);
```

## Use the Language's Doc-Comment Convention

Write interface comments in the target language's native doc-comment style.

**TypeScript / JavaScript (JSDoc/TSDoc)**

```typescript
/**
 * Charges the order total and returns the confirmed payment.
 *
 * @param order - Order to charge; its `total` must be > 0.
 * @param gateway - Payment boundary; injected for testability.
 * @returns The confirmed payment.
 * @throws PaymentDeclinedError when the gateway rejects the charge.
 */
function processPayment(order: Order, gateway: PaymentGateway): Payment {}
```

**PHP (PHPDoc)**

```php
/**
 * Charges the order total and returns the confirmed payment.
 *
 * @param Order $order Order to charge; its total must be > 0.
 * @throws PaymentDeclinedException When the gateway rejects the charge.
 */
public function processPayment(Order $order): Payment {}
```

**Java (Javadoc)**

```java
/**
 * Charges the order total and returns the confirmed payment.
 *
 * @param order order to charge; its total must be positive
 * @return the confirmed payment
 * @throws PaymentDeclinedException if the gateway rejects the charge
 */
Payment processPayment(Order order) {}
```

**Python (docstring)**

```python
def process_payment(order: Order, gateway: PaymentGateway) -> Payment:
    """Charge the order total and return the confirmed payment.

    Args:
        order: Order to charge; its total must be > 0.
        gateway: Payment boundary; injected for testability.

    Raises:
        PaymentDeclined: If the gateway rejects the charge.
    """
```
