USE OlistECommerce;
GO

-- Cleaning of the core layer.
-- Run after 05, because 05 truncates the core tables and would remove everything added here.
--
-- After 05 the core tables show the data exactly as it is in the source.
-- All corrections are made here, so every change to the data is documented.
-- The script can be run many times, a repeated run changes nothing.
-- After each fix, run the matching check from 06.

-- 1. Missing category translations.
-- 13 products belong to 2 categories that have no row in core.category_translation,
-- so a foreign key from products to category_translation would fail.
-- The English names are my own translations, they are not in the dataset.
-- Check: points 7a and 7b in 06 should return 0 and an empty list.
INSERT INTO core.category_translation (product_category_name, product_category_name_english)
SELECT v.product_category_name, v.product_category_name_english
FROM (VALUES
	('pc_gamer', 'pc_gamer'),
	('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers')
) AS v (product_category_name, product_category_name_english)
WHERE NOT EXISTS (
	SELECT 1
	FROM core.category_translation AS ct
	WHERE ct.product_category_name = v.product_category_name
);

