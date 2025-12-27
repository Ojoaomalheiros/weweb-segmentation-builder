# Bug: RPC front_segmento_carregar_editar não retorna dados completos de produtos e categorias

**Data:** 2025-12-26
**Prioridade:** Alta
**Status:** Bloqueador para funcionalidade de edição
**Componente:** Backend - RPC `front_segmento_carregar_editar`

---

## 📋 Resumo do Problema

A RPC `front_segmento_carregar_editar` **não está retornando** os campos `valueUuid` e `productName`/`categoryName` para condições que envolvem produtos ou categorias, impossibilitando a edição correta de segmentos no frontend.

---

## 🔍 Reprodução do Problema

### 1. Cenário de Teste

1. Criar um segmento com uma condição de **produto**
2. Salvar o segmento (ID: 54)
3. Tentar **editar** o segmento (carregar via RPC)
4. **Resultado:** O campo de produto aparece **vazio** no frontend

### 2. Chamada RPC Realizada

```javascript
// Frontend chama:
await supabaseClient.rpc('front_segmento_carregar_editar', {
  payload: {
    segmento: 54,
    empresa: 1002
  }
})
```

---

## ❌ Dados Retornados Atualmente (INCORRETO)

### Estrutura Retornada pelo Backend:

```json
{
  "nome": "Nome do Segmento",
  "descricao": "Descrição",
  "groups": [
    {
      "conditions": [
        {
          "field": "frequency",
          "operator": "<=",
          "valueMin": "5",
          "valueMax": "",
          "timeOperator": "over_all_time",
          "days": "",
          "startDate": null,
          "endDate": null,
          "unique_id": "42"
        },
        {
          "field": "produto",
          "operator": "=",
          "valueMin": "",
          "valueMax": "",
          "timeOperator": "over_all_time",
          "days": "",
          "startDate": null,
          "endDate": null,
          "unique_id": "43"
          // ❌ FALTANDO: valueUuid
          // ❌ FALTANDO: productName
        }
      ]
    }
  ]
}
```

### Log do Console (Evidência):

```
🔍 Condition 0-1: Object
  days: ""
  endDate: null
  field: "produto"
  operator: "="
  startDate: null
  timeOperator: "over_all_time"
  unique_id: "43"
  valueMax: ""
  valueMin: ""
  // ❌ SEM valueUuid
  // ❌ SEM productName
```

---

## ✅ Dados Esperados (CORRETO)

### Estrutura Esperada pelo Frontend:

```json
{
  "nome": "Nome do Segmento",
  "descricao": "Descrição",
  "groups": [
    {
      "conditions": [
        {
          "field": "frequency",
          "operator": "<=",
          "valueMin": "5",
          "valueMax": "",
          "timeOperator": "over_all_time",
          "days": "",
          "startDate": null,
          "endDate": null,
          "unique_id": "42"
        },
        {
          "field": "produto",
          "operator": "=",
          "valueUuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",  // ✅ NECESSÁRIO
          "productName": "Caneta Azul BIC",                       // ✅ RECOMENDADO
          "valueMin": "",
          "valueMax": "",
          "timeOperator": "over_all_time",
          "days": "",
          "startDate": null,
          "endDate": null,
          "unique_id": "43"
        }
      ]
    }
  ]
}
```

---

## 📊 Campos Necessários por Tipo de Condição

| Tipo de Campo | Campo `field` | Campos Obrigatórios | Campos Opcionais (mas recomendados) |
|---------------|---------------|---------------------|--------------------------------------|
| **Produto** | `produto` | `valueUuid` (UUID do produto) | `productName` (nome do produto) |
| **Categoria** | `categoria` | `valueUuid` (UUID da categoria) | `categoryName` (nome da categoria) |
| **Texto** | `name`, `email`, etc. | `valueText` (valor em texto) | - |
| **Numérico** | `age`, `frequency`, etc. | `valueMin`, `valueMax` (se between) | - |
| **Booleano** | `is_active`, etc. | `valueMin` (0 ou 1) | - |
| **UUID** | `user_id`, etc. | `valueUuid` (UUID) | - |
| **Data** | `created_at`, `birthday`, etc. | `days` ou `startDate`/`endDate` | - |

---

## 🔧 Correção Necessária

### Modificar a RPC `front_segmento_carregar_editar`

A RPC deve incluir **JOIN** com as tabelas de produtos e categorias para retornar os nomes:

```sql
-- Pseudocódigo da correção necessária

-- Para condições com field = 'produto'
SELECT
  c.*,
  p.nome as productName  -- ✅ ADICIONAR JOIN com tabela produtos
FROM condicoes c
LEFT JOIN produtos p ON p.id::text = c.value_uuid
WHERE c.field = 'produto';

-- Para condições com field = 'categoria'
SELECT
  c.*,
  cat.nome as categoryName  -- ✅ ADICIONAR JOIN com tabela categorias
FROM condicoes c
LEFT JOIN categorias cat ON cat.id::text = c.value_uuid
WHERE c.field = 'categoria';
```

### Estrutura de Retorno Corrigida:

```typescript
// Typescript/PostgreSQL function
interface Condition {
  field: string;
  operator: string;

  // Valores primitivos
  valueText?: string;      // Para campos de texto
  valueUuid?: string;      // Para produtos, categorias, UUIDs
  valueMin?: number;       // Para numéricos
  valueMax?: number;       // Para range numérico
  valueList?: string[];    // Para arrays

  // Nomes para exibição (obtidos via JOIN)
  productName?: string;    // ✅ ADICIONAR - nome do produto (se field = 'produto')
  categoryName?: string;   // ✅ ADICIONAR - nome da categoria (se field = 'categoria')

  // Filtros temporais
  timeOperator?: string;
  days?: number;
  startDate?: string;
  endDate?: string;

  // Metadata
  unique_id: string;
}
```

---

## 🎯 Casos de Uso Afetados

### Sem a Correção (Estado Atual):
1. ❌ Usuário edita segmento → campo de produto aparece **vazio**
2. ❌ Usuário não sabe qual produto estava selecionado
3. ❌ Usuário precisa selecionar o produto novamente (perda de dados)
4. ❌ Usuário edita categoria → campo de categoria aparece **vazio**

### Com a Correção:
1. ✅ Usuário edita segmento → campo de produto mostra **"Caneta Azul BIC"**
2. ✅ Usuário vê exatamente qual produto estava selecionado
3. ✅ Usuário pode alterar ou manter a seleção
4. ✅ Usuário edita categoria → campo mostra **"Escritório > Material de Escritório"**

---

## 📝 Checklist para Backend Specialist

- [ ] Verificar estrutura da tabela de condições/segmentos
- [ ] Identificar onde `valueUuid` é armazenado para produtos
- [ ] Identificar onde `valueUuid` é armazenado para categorias
- [ ] Adicionar JOIN com tabela `produtos` quando `field = 'produto'`
- [ ] Adicionar JOIN com tabela `categorias` quando `field = 'categoria'`
- [ ] Incluir `productName` no retorno (coluna `nome` da tabela produtos)
- [ ] Incluir `categoryName` no retorno (coluna `nome` da tabela categorias)
- [ ] Testar RPC retornando dados completos
- [ ] Validar que frontend recebe `valueUuid` e nomes corretamente

---

## 🧪 Teste de Validação

### Como testar a correção:

1. **Criar segmento de teste:**
```sql
-- Criar segmento com condição de produto
INSERT INTO segmentos (nome, empresa_id)
VALUES ('Teste Produto', 1002);

-- Adicionar condição de produto
INSERT INTO condicoes (segmento_id, field, operator, value_uuid)
VALUES (
  <id_do_segmento>,
  'produto',
  '=',
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890'  -- UUID de um produto real
);
```

2. **Chamar RPC corrigida:**
```sql
SELECT * FROM front_segmento_carregar_editar(
  '{"segmento": <id_do_segmento>, "empresa": 1002}'::jsonb
);
```

3. **Validar retorno:**
```json
// Deve incluir:
{
  "conditions": [{
    "field": "produto",
    "operator": "=",
    "valueUuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",  // ✅
    "productName": "Nome Real do Produto"                  // ✅
  }]
}
```

---

## 📞 Informações de Contato

- **Frontend Developer:** João Malheiros
- **Projeto:** FlashCRM - Segmentação de Clientes v3
- **Componente:** WeWeb Custom Component - Segmentation Builder
- **RPC Afetada:** `front_segmento_carregar_editar`
- **Ambiente:** Produção (opusynwybctjfagfwmjz.supabase.co)

---

## 📎 Referências

- **Documento de Debug Edge Function:** `DEBUG_EDGE_FUNCTION_CALL.md`
- **Guia de Implementação Frontend:** `GUIA-IMPLEMENTACAO-FRONTEND-SEGMENTACAO-V3.md`
- **Repositório GitHub:** https://github.com/Ojoaomalheiros/weweb-segmentation-builder.git
- **Commit com Debug Log:** `d7ee46d`

---

**Data do Relatório:** 2025-12-26
**Preparado por:** Frontend Developer
**Para:** Backend Specialist
