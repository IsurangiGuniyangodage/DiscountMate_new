-- products: one row per unique product, keyed by product_code
CREATE TABLE products (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_code    TEXT NOT NULL UNIQUE,
    name            TEXT NOT NULL,
    brand           TEXT,
    category        TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_products_category ON products (category);
CREATE INDEX idx_products_name ON products USING gin (to_tsvector('english', name));

-- product_pricings: one row per price observation, per store chain, per product
-- Enforces a real FK to products.id -- no legacy product_code fallback matching.
CREATE TABLE product_pricings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id      UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    store_chain     TEXT NOT NULL,  -- e.g. 'coles_generic', 'woolworths_generic', 'iga_generic'
    price           NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    observed_date   DATE NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_pricings_product_chain_date
    ON product_pricings (product_id, store_chain, observed_date DESC);