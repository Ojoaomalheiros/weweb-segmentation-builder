-- ============================================================================
-- Script de Dados de Teste - Empresa 1003
-- Criado: 2025-12-26
-- Objetivo: Popular banco com dados de teste para validação de segmentação
-- ============================================================================

-- ============================================================================
-- 1. CRIAR EMPRESA
-- ============================================================================

INSERT INTO empresas (id, nome, ativo, created_at)
VALUES (
  1003,
  'Empresa Teste Segmentação',
  true,
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  ativo = EXCLUDED.ativo;

-- ============================================================================
-- 2. CRIAR CATEGORIAS
-- ============================================================================

-- Categoria Raiz: Eletrônicos
INSERT INTO categorias (id, nome, empresa_id, parent_id, ativo, created_at)
VALUES
  ('11111111-1111-1111-1111-111111111001'::uuid, 'Eletrônicos', 1003, NULL, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Subcategorias de Eletrônicos
INSERT INTO categorias (id, nome, empresa_id, parent_id, ativo, created_at)
VALUES
  ('11111111-1111-1111-1111-111111111002'::uuid, 'Smartphones', 1003, '11111111-1111-1111-1111-111111111001'::uuid, true, NOW()),
  ('11111111-1111-1111-1111-111111111003'::uuid, 'Notebooks', 1003, '11111111-1111-1111-1111-111111111001'::uuid, true, NOW()),
  ('11111111-1111-1111-1111-111111111004'::uuid, 'Acessórios', 1003, '11111111-1111-1111-1111-111111111001'::uuid, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Categoria Raiz: Moda
INSERT INTO categorias (id, nome, empresa_id, parent_id, ativo, created_at)
VALUES
  ('22222222-2222-2222-2222-222222222001'::uuid, 'Moda', 1003, NULL, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Subcategorias de Moda
INSERT INTO categorias (id, nome, empresa_id, parent_id, ativo, created_at)
VALUES
  ('22222222-2222-2222-2222-222222222002'::uuid, 'Camisetas', 1003, '22222222-2222-2222-2222-222222222001'::uuid, true, NOW()),
  ('22222222-2222-2222-2222-222222222003'::uuid, 'Calças', 1003, '22222222-2222-2222-2222-222222222001'::uuid, true, NOW()),
  ('22222222-2222-2222-2222-222222222004'::uuid, 'Tênis', 1003, '22222222-2222-2222-2222-222222222001'::uuid, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 3. CRIAR PRODUTOS
-- ============================================================================

-- Produtos de Eletrônicos
INSERT INTO produtos (id, nome, categoria_id, empresa_id, imagem, ativo, created_at)
VALUES
  (
    '33333333-3333-3333-3333-333333333001'::uuid,
    'iPhone 15 Pro Max',
    '11111111-1111-1111-1111-111111111002'::uuid,
    1003,
    'https://images.unsplash.com/photo-1592286927505-ed6c03b5ee5d?w=200',
    true,
    NOW()
  ),
  (
    '33333333-3333-3333-3333-333333333002'::uuid,
    'Samsung Galaxy S24 Ultra',
    '11111111-1111-1111-1111-111111111002'::uuid,
    1003,
    'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=200',
    true,
    NOW()
  ),
  (
    '33333333-3333-3333-3333-333333333003'::uuid,
    'MacBook Pro M3',
    '11111111-1111-1111-1111-111111111003'::uuid,
    1003,
    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=200',
    true,
    NOW()
  ),
  (
    '33333333-3333-3333-3333-333333333004'::uuid,
    'Dell XPS 15',
    '11111111-1111-1111-1111-111111111003'::uuid,
    1003,
    'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=200',
    true,
    NOW()
  ),
  (
    '33333333-3333-3333-3333-333333333005'::uuid,
    'Fone AirPods Pro',
    '11111111-1111-1111-1111-111111111004'::uuid,
    1003,
    'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=200',
    true,
    NOW()
  )
ON CONFLICT (id) DO NOTHING;

-- Produtos de Moda
INSERT INTO produtos (id, nome, categoria_id, empresa_id, imagem, ativo, created_at)
VALUES
  (
    '44444444-4444-4444-4444-444444444001'::uuid,
    'Camiseta Nike Dry-Fit',
    '22222222-2222-2222-2222-222222222002'::uuid,
    1003,
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200',
    true,
    NOW()
  ),
  (
    '44444444-4444-4444-4444-444444444002'::uuid,
    'Camiseta Adidas Essentials',
    '22222222-2222-2222-2222-222222222002'::uuid,
    1003,
    'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=200',
    true,
    NOW()
  ),
  (
    '44444444-4444-4444-4444-444444444003'::uuid,
    'Calça Jeans Levis 501',
    '22222222-2222-2222-2222-222222222003'::uuid,
    1003,
    'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200',
    true,
    NOW()
  ),
  (
    '44444444-4444-4444-4444-444444444004'::uuid,
    'Tênis Nike Air Max',
    '22222222-2222-2222-2222-222222222004'::uuid,
    1003,
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200',
    true,
    NOW()
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 4. VARIAÇÕES DE PRODUTOS (Cores e Tamanhos)
-- ============================================================================

-- Cores disponíveis para produtos de moda
INSERT INTO produto_atributos (produto_id, atributo, valor)
VALUES
  -- Camiseta Nike
  ('44444444-4444-4444-4444-444444444001'::uuid, 'color', 'Preto'),
  ('44444444-4444-4444-4444-444444444001'::uuid, 'color', 'Branco'),
  ('44444444-4444-4444-4444-444444444001'::uuid, 'color', 'Azul'),
  ('44444444-4444-4444-4444-444444444001'::uuid, 'size', 'P'),
  ('44444444-4444-4444-4444-444444444001'::uuid, 'size', 'M'),
  ('44444444-4444-4444-4444-444444444001'::uuid, 'size', 'G'),
  ('44444444-4444-4444-4444-444444444001'::uuid, 'size', 'GG'),

  -- Camiseta Adidas
  ('44444444-4444-4444-4444-444444444002'::uuid, 'color', 'Cinza'),
  ('44444444-4444-4444-4444-444444444002'::uuid, 'color', 'Verde'),
  ('44444444-4444-4444-4444-444444444002'::uuid, 'size', 'P'),
  ('44444444-4444-4444-4444-444444444002'::uuid, 'size', 'M'),
  ('44444444-4444-4444-4444-444444444002'::uuid, 'size', 'G'),

  -- Calça Jeans
  ('44444444-4444-4444-4444-444444444003'::uuid, 'color', 'Azul Escuro'),
  ('44444444-4444-4444-4444-444444444003'::uuid, 'color', 'Azul Claro'),
  ('44444444-4444-4444-4444-444444444003'::uuid, 'size', '38'),
  ('44444444-4444-4444-4444-444444444003'::uuid, 'size', '40'),
  ('44444444-4444-4444-4444-444444444003'::uuid, 'size', '42'),
  ('44444444-4444-4444-4444-444444444003'::uuid, 'size', '44'),

  -- Tênis Nike
  ('44444444-4444-4444-4444-444444444004'::uuid, 'color', 'Preto'),
  ('44444444-4444-4444-4444-444444444004'::uuid, 'color', 'Branco'),
  ('44444444-4444-4444-4444-444444444004'::uuid, 'color', 'Vermelho'),
  ('44444444-4444-4444-4444-444444444004'::uuid, 'size', '38'),
  ('44444444-4444-4444-4444-444444444004'::uuid, 'size', '39'),
  ('44444444-4444-4444-4444-444444444004'::uuid, 'size', '40'),
  ('44444444-4444-4444-4444-444444444004'::uuid, 'size', '41'),
  ('44444444-4444-4444-4444-444444444004'::uuid, 'size', '42')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 5. CRIAR CLIENTES
-- ============================================================================

INSERT INTO clientes (id, nome, email, telefone, empresa_id, gender, age, created_at, birthday)
VALUES
  (
    '55555555-5555-5555-5555-555555555001'::uuid,
    'João Silva',
    'joao.silva@email.com',
    '+5511987654321',
    1003,
    'masculino',
    35,
    NOW() - INTERVAL '2 years',
    '1989-03-15'
  ),
  (
    '55555555-5555-5555-5555-555555555002'::uuid,
    'Maria Santos',
    'maria.santos@email.com',
    '+5511987654322',
    1003,
    'feminino',
    28,
    NOW() - INTERVAL '1 year',
    '1996-07-22'
  ),
  (
    '55555555-5555-5555-5555-555555555003'::uuid,
    'Pedro Costa',
    'pedro.costa@email.com',
    '+5511987654323',
    1003,
    'masculino',
    42,
    NOW() - INTERVAL '3 years',
    '1982-11-08'
  ),
  (
    '55555555-5555-5555-5555-555555555004'::uuid,
    'Ana Oliveira',
    'ana.oliveira@email.com',
    '+5511987654324',
    1003,
    'feminino',
    31,
    NOW() - INTERVAL '6 months',
    '1993-05-18'
  ),
  (
    '55555555-5555-5555-5555-555555555005'::uuid,
    'Carlos Ferreira',
    'carlos.ferreira@email.com',
    '+5511987654325',
    1003,
    'masculino',
    25,
    NOW() - INTERVAL '3 months',
    '1999-09-30'
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 6. CRIAR PEDIDOS
-- ============================================================================

-- Pedidos de João Silva (cliente fiel, alta frequência)
INSERT INTO pedidos (id, cliente_id, empresa_id, total, status, created_at)
VALUES
  (
    '66666666-6666-6666-6666-666666666001'::uuid,
    '55555555-5555-5555-5555-555555555001'::uuid,
    1003,
    5999.00,
    'completed',
    NOW() - INTERVAL '60 days'
  ),
  (
    '66666666-6666-6666-6666-666666666002'::uuid,
    '55555555-5555-5555-5555-555555555001'::uuid,
    1003,
    399.90,
    'completed',
    NOW() - INTERVAL '30 days'
  ),
  (
    '66666666-6666-6666-6666-666666666003'::uuid,
    '55555555-5555-5555-5555-555555555001'::uuid,
    1003,
    1299.00,
    'completed',
    NOW() - INTERVAL '15 days'
  ),
  (
    '66666666-6666-6666-6666-666666666004'::uuid,
    '55555555-5555-5555-5555-555555555001'::uuid,
    1003,
    899.90,
    'completed',
    NOW() - INTERVAL '5 days'
  ),

  -- Pedidos de Maria Santos (cliente médio)
  (
    '66666666-6666-6666-6666-666666666005'::uuid,
    '55555555-5555-5555-5555-555555555002'::uuid,
    1003,
    3499.00,
    'completed',
    NOW() - INTERVAL '90 days'
  ),
  (
    '66666666-6666-6666-6666-666666666006'::uuid,
    '55555555-5555-5555-5555-555555555002'::uuid,
    1003,
    599.90,
    'completed',
    NOW() - INTERVAL '45 days'
  ),

  -- Pedidos de Pedro Costa (cliente VIP, alto valor)
  (
    '66666666-6666-6666-6666-666666666007'::uuid,
    '55555555-5555-5555-5555-555555555003'::uuid,
    1003,
    12999.00,
    'completed',
    NOW() - INTERVAL '120 days'
  ),
  (
    '66666666-6666-6666-6666-666666666008'::uuid,
    '55555555-5555-5555-5555-555555555003'::uuid,
    1003,
    8999.00,
    'completed',
    NOW() - INTERVAL '20 days'
  ),

  -- Pedidos de Ana Oliveira (cliente novo)
  (
    '66666666-6666-6666-6666-666666666009'::uuid,
    '55555555-5555-5555-5555-555555555004'::uuid,
    1003,
    1799.00,
    'completed',
    NOW() - INTERVAL '10 days'
  ),

  -- Pedidos de Carlos Ferreira (cliente inativo)
  (
    '66666666-6666-6666-6666-666666666010'::uuid,
    '55555555-5555-5555-5555-555555555005'::uuid,
    1003,
    299.90,
    'completed',
    NOW() - INTERVAL '180 days'
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 7. ITENS DOS PEDIDOS
-- ============================================================================

-- Itens do pedido 1 de João (MacBook)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666001'::uuid, '33333333-3333-3333-3333-333333333003'::uuid, 1, 5999.00, NULL, NULL);

-- Itens do pedido 2 de João (Camiseta)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666002'::uuid, '44444444-4444-4444-4444-444444444001'::uuid, 2, 199.95, 'Preto', 'G');

-- Itens do pedido 3 de João (Tênis)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666003'::uuid, '44444444-4444-4444-4444-444444444004'::uuid, 1, 1299.00, 'Branco', '42');

-- Itens do pedido 4 de João (Fone)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666004'::uuid, '33333333-3333-3333-3333-333333333005'::uuid, 1, 899.90, NULL, NULL);

-- Itens do pedido 5 de Maria (Dell XPS)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666005'::uuid, '33333333-3333-3333-3333-333333333004'::uuid, 1, 3499.00, NULL, NULL);

-- Itens do pedido 6 de Maria (Calça Jeans)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666006'::uuid, '44444444-4444-4444-4444-444444444003'::uuid, 2, 299.95, 'Azul Escuro', '40');

-- Itens dos pedidos de Pedro (iPhone + Samsung)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666007'::uuid, '33333333-3333-3333-3333-333333333001'::uuid, 1, 12999.00, NULL, NULL),
  ('66666666-6666-6666-6666-666666666008'::uuid, '33333333-3333-3333-3333-333333333002'::uuid, 1, 8999.00, NULL, NULL);

-- Itens do pedido de Ana (Camiseta + Tênis)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666009'::uuid, '44444444-4444-4444-4444-444444444002'::uuid, 2, 149.95, 'Cinza', 'M'),
  ('66666666-6666-6666-6666-666666666009'::uuid, '44444444-4444-4444-4444-444444444004'::uuid, 1, 1299.00, 'Preto', '38');

-- Itens do pedido de Carlos (Camiseta)
INSERT INTO pedido_itens (pedido_id, produto_id, quantidade, preco_unitario, variation_color, variation_size)
VALUES
  ('66666666-6666-6666-6666-666666666010'::uuid, '44444444-4444-4444-4444-444444444001'::uuid, 1, 299.90, 'Branco', 'P');

ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. CRIAR SEGMENTOS DE EXEMPLO
-- ============================================================================

-- Segmento 1: Clientes VIP (alto valor)
INSERT INTO segmentos (id, nome, descricao, empresa_id, created_at)
VALUES
  (
    101,
    'Clientes VIP',
    'Clientes com ticket médio acima de R$ 5.000',
    1003,
    NOW()
  )
ON CONFLICT (id) DO NOTHING;

-- Segmento 2: Compradores Frequentes
INSERT INTO segmentos (id, nome, descricao, empresa_id, created_at)
VALUES
  (
    102,
    'Compradores Frequentes',
    'Clientes que compraram mais de 3 vezes nos últimos 90 dias',
    1003,
    NOW()
  )
ON CONFLICT (id) DO NOTHING;

-- Segmento 3: Fãs de Eletrônicos
INSERT INTO segmentos (id, nome, descricao, empresa_id, created_at)
VALUES
  (
    103,
    'Fãs de Eletrônicos',
    'Clientes que compraram produtos da categoria Eletrônicos',
    1003,
    NOW()
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 9. RFM SEGMENTS (se aplicável)
-- ============================================================================

-- Atualizar clientes com RFM segments
UPDATE clientes
SET rfm_segment = 'champions'
WHERE id = '55555555-5555-5555-5555-555555555001'::uuid;

UPDATE clientes
SET rfm_segment = 'loyal'
WHERE id = '55555555-5555-5555-5555-555555555003'::uuid;

UPDATE clientes
SET rfm_segment = 'recent_customers'
WHERE id = '55555555-5555-5555-5555-555555555004'::uuid;

UPDATE clientes
SET rfm_segment = 'at_risk'
WHERE id IN (
  '55555555-5555-5555-5555-555555555002'::uuid,
  '55555555-5555-5555-5555-555555555005'::uuid
);

-- ============================================================================
-- 10. VERIFICAÇÕES FINAIS
-- ============================================================================

-- Verificar empresa criada
SELECT * FROM empresas WHERE id = 1003;

-- Verificar categorias criadas
SELECT id, nome, parent_id FROM categorias WHERE empresa_id = 1003 ORDER BY nome;

-- Verificar produtos criados
SELECT p.id, p.nome, c.nome as categoria
FROM produtos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.empresa_id = 1003
ORDER BY c.nome, p.nome;

-- Verificar clientes criados
SELECT id, nome, email, age, gender, rfm_segment
FROM clientes
WHERE empresa_id = 1003
ORDER BY nome;

-- Verificar pedidos e totais
SELECT
  c.nome as cliente,
  COUNT(p.id) as total_pedidos,
  SUM(p.total) as valor_total
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
WHERE p.empresa_id = 1003
GROUP BY c.nome
ORDER BY valor_total DESC;

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================

COMMENT ON TABLE empresas IS 'Script executado em 2025-12-26 - Empresa 1003 criada com dados de teste';
