#!/usr/bin/env python3
import sys

def calculate_interest(amount: float, months: int, annual_rate: float) -> float:
    """
    Simulate fixed amount repayments and calculate total interest.
    """
    monthly_payment = amount / months
    accumulated_interest = 0.0

    # Header
    print(f"{'Month':<6} | {'Interest':>12} | {'Balance':>12}")
    print("-" * 36)

    for i in range(1, months + 1):
        monthly_interest = (amount * annual_rate / 100) / 12
        accumulated_interest += monthly_interest
        amount -= monthly_payment

        print(f"{i:02d}    | ${monthly_interest:>11,.2f} | ${amount:>11,.2f}")

    print("-" * 36)
    print(f"\nAccumulated interest: ${accumulated_interest:,.2f}")
    print(f"Recovered percentage: {accumulated_interest / (monthly_payment * months) * 100:.2f}%")

    return accumulated_interest


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: loan.py <amount> <months> <annual_rate>")
        sys.exit(1)

    try:
        amount = float(sys.argv[1])
        months = int(sys.argv[2])
        annual_rate = float(sys.argv[3])
    except ValueError:
        print("Invalid input. Amount and rate must be numbers; months must be an integer.")
        sys.exit(1)

    if amount <= 0 or months <= 0 or annual_rate < 0:
        print("Amount and months must be positive; rate must be non-negative.")
        sys.exit(1)

    monthly_payment = amount / months
    print(f"Loan: ${amount:,.2f} Monthly payment: ${monthly_payment:,.2f}")
    print(f"Period: {months} months | Annual rate: {annual_rate:.2f}%\n")

    calculate_interest(amount, months, annual_rate)
