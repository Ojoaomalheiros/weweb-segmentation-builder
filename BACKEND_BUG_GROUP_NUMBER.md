# Bug: RPC front_segmento_criar_novo_v2 não salva group_number

**Data:** 2025-12-27
**Prioridade:** ALTA - Bloqueador
**Status:** Backend não está salvando `group_number`
**Componente:** Backend - RPC `front_segmento_criar_novo_v2`

---

## 📋 Resumo do Problema

A RPC `front_segmento_criar_novo_v2` **recebe** o campo `group_number` no payload, mas **não está salvando** na coluna `group_number` da tabela `segmento_criterios`.

---

## 🔍 Evidência

### Payload Enviado pelo Frontend (CORRETO):

```json
{
  "empresa": 1003,
  "nome": "iphone pro desde sempre",
  "descricao": "iphone pro desde sempre",
  "groups": [
    {
      "groupNumber": 1,
      "conditions": [
        {
          "field": "product_id",
          "operator": "=",
          "groupNumber": 1,       // ✅ ENVIADO
          "group_number": 1,      // ✅ ENVIADO (snake_case)
          "valueUuid": "c4773ce1-1792-4c8d-890d-ebf0ed114fa0",
          "timeOperator": "over_all_time"
        }
      ]
    }
  ],
  "id": 105,
  "version": "2"
}
```

### Dados Salvos no Banco (INCORRETO):

```json
[
  {
    "idx": 29,
    "id": 121,
    "segmento_id": 105,
    "field": "product_id",
    "operator": "=",
    "value_min": null,
    "value_max": null,
    "time_operator": "over_all_time",
    "days": null,
    "start_date": null,
    "end_date": null,
    "group_number": null,  // ❌ SALVO COMO NULL
    "date_format": null,
    "value_list": null,
    "value_text": null,
    "version": 3,
    "value_uuid": "c4773ce1-1792-4c8d-890d-ebf0ed114fa0",
    "value_uuid_list": null
  }
]
```

---

## ❌ Comportamento Atual (INCORRETO)

1. Frontend envia payload com `group_number: 1`
2. Backend **RECEBE** o payload corretamente
3. Backend salva na tabela `segmento_criterios`
4. ❌ Coluna `group_number` fica como `NULL`

---

## ✅ Comportamento Esperado (CORRETO)

1. Frontend envia payload com `group_number: 1`
2. Backend **RECEBE** o payload
3. Backend salva na tabela `segmento_criterios`
4. ✅ Coluna `group_number` deve ter valor `1`

---

## 🔧 Correção Necessária

### Na RPC `front_segmento_criar_novo_v2`:

O backend precisa **ler** e **salvar** o campo `group_number` de cada condição:

```sql
-- Pseudocódigo da correção necessária

-- Quando processar cada condição do payload
FOR EACH condition IN payload.groups[].conditions:

  -- Extrair group_number da condição
  group_number_value = condition.group_number OR condition.groupNumber

  -- Salvar na tabela
  INSERT INTO segmento_criterios (
    segmento_id,
    field,
    operator,
    group_number,  -- ✅ INCLUIR ESTE CAMPO
    value_uuid,
    time_operator,
    version,
    ...
  ) VALUES (
    segmento_id,
    condition.field,
    condition.operator,
    group_number_value,  -- ✅ VALOR DO PAYLOAD
    condition.valueUuid,
    condition.timeOperator,
    payload.version,
    ...
  );
```

### Verificação de Compatibilidade:

O payload envia **AMBOS** os formatos:
- `groupNumber` (camelCase - padrão JavaScript)
- `group_number` (snake_case - padrão SQL)

O backend pode ler qualquer um dos dois:

```typescript
// TypeScript/JavaScript
const groupNumber = condition.group_number || condition.groupNumber;
```

```sql
-- SQL/PL/pgSQL
group_number := COALESCE(
  (payload->'group_number')::int,
  (payload->'groupNumber')::int
);
```

---

## 🧪 Teste de Validação

### 1. Criar Segmento com 1 Grupo:

```json
{
  "empresa": 1003,
  "nome": "Teste 1 Grupo",
  "groups": [
    {
      "groupNumber": 1,
      "conditions": [
        {
          "field": "frequency",
          "operator": ">=",
          "groupNumber": 1,
          "group_number": 1,
          "valueMin": 5
        }
      ]
    }
  ]
}
```

**Validação:**
```sql
SELECT id, field, operator, group_number, value_min
FROM segmento_criterios
WHERE segmento_id = <id_do_segmento>;
```

**Resultado Esperado:**
```
id | field     | operator | group_number | value_min
---|-----------|----------|--------------|----------
1  | frequency | >=       | 1            | 5
```

### 2. Criar Segmento com 2 Grupos:

```json
{
  "empresa": 1003,
  "nome": "Teste 2 Grupos",
  "groups": [
    {
      "groupNumber": 1,
      "conditions": [
        {
          "field": "product_id",
          "operator": "=",
          "groupNumber": 1,
          "group_number": 1,
          "valueUuid": "abc-123"
        }
      ]
    },
    {
      "groupNumber": 2,
      "conditions": [
        {
          "field": "frequency",
          "operator": ">=",
          "groupNumber": 2,
          "group_number": 2,
          "valueMin": 3
        }
      ]
    }
  ]
}
```

**Validação:**
```sql
SELECT id, field, operator, group_number
FROM segmento_criterios
WHERE segmento_id = <id_do_segmento>
ORDER BY group_number, id;
```

**Resultado Esperado:**
```
id | field      | operator | group_number
---|------------|----------|-------------
1  | product_id | =        | 1
2  | frequency  | >=       | 2
```

---

## 🎯 Impacto do Bug

### Sem Correção:
1. ❌ Todas as condições ficam com `group_number = NULL`
2. ❌ Backend não consegue separar condições por grupo
3. ❌ Lógica de segmentação fica incorreta (AND vs OR)
4. ❌ Clientes são segmentados de forma errada
5. ❌ Campanhas vão para público incorreto

### Com Correção:
1. ✅ Condições são corretamente agrupadas
2. ✅ Lógica AND/OR funciona conforme esperado
3. ✅ Segmentação precisa
4. ✅ Campanhas atingem público correto

---

## 📊 Estrutura da Tabela

### Tabela `segmento_criterios`:

```sql
CREATE TABLE segmento_criterios (
  id SERIAL PRIMARY KEY,
  segmento_id INTEGER REFERENCES segmentos(id),
  field VARCHAR(100),
  operator VARCHAR(20),
  group_number INTEGER,  -- ❌ Coluna existe, mas fica NULL
  value_text TEXT,
  value_uuid UUID,
  value_min NUMERIC,
  value_max NUMERIC,
  time_operator VARCHAR(50),
  days INTEGER,
  start_date DATE,
  end_date DATE,
  version INTEGER,
  ...
);
```

---

## 📝 Checklist para Backend Specialist

- [ ] Localizar código da RPC `front_segmento_criar_novo_v2`
- [ ] Identificar onde as condições são processadas
- [ ] Verificar se `group_number` está sendo lido do payload
- [ ] Adicionar leitura de `condition.group_number` ou `condition.groupNumber`
- [ ] Incluir `group_number` no INSERT da tabela `segmento_criterios`
- [ ] Testar com 1 grupo (todas condições com `group_number = 1`)
- [ ] Testar com 2+ grupos (condições com `group_number = 1, 2, 3...`)
- [ ] Validar que `group_number` não fica NULL
- [ ] Testar edição de segmento existente
- [ ] Validar retrocompatibilidade com versões antigas

---

## 📞 Informações de Contato

- **Frontend Developer:** João Malheiros
- **Projeto:** FlashCRM - Segmentação de Clientes v3
- **Componente:** WeWeb Custom Component - Segmentation Builder
- **RPC Afetada:** `front_segmento_criar_novo_v2`
- **Tabela Afetada:** `segmento_criterios`
- **Coluna Afetada:** `group_number`

---

## 📎 Referências

- **Log do Console (Evidência):** Veja seção "Evidência" acima
- **Payload Completo:** JSON fornecido mostra `group_number: 1` sendo enviado
- **Dados do Banco:** JSON mostra `"group_number": null` sendo salvo
- **Repositório Frontend:** https://github.com/Ojoaomalheiros/weweb-segmentation-builder.git
- **Último Commit:** `47c84e5` - Added detailed JSON logging

---

**Data do Relatório:** 2025-12-27
**Preparado por:** Frontend Developer
**Para:** Backend Specialist

**URGÊNCIA:** Este bug impede o correto funcionamento da segmentação. Por favor, priorize a correção.
