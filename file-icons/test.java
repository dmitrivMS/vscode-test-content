package com.example.inventory;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class InventoryManager {
    private final Map<String, Integer> stock = new HashMap<>();

    public void addItem(String sku, int quantity) {
        stock.merge(sku, quantity, Integer::sum);
    }

    public boolean removeItem(String sku, int quantity) {
        int current = stock.getOrDefault(sku, 0);
        if (current < quantity) {
            return false;
        }
        stock.put(sku, current - quantity);
        return true;
    }

    public Optional<Integer> getQuantity(String sku) {
        return Optional.ofNullable(stock.get(sku));
    }

    public int getTotalItems() {
        return stock.values().stream().mapToInt(Integer::intValue).sum();
    }
}
