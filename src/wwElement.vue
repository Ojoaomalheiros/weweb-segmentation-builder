<template>
  <div class="segmentation-builder" :style="wrapperStyle">
    <!-- Header -->
    <div class="builder-header">
      <h2 class="title">{{ content?.title || 'Criar Segmento' }}</h2>
      <p v-if="content?.description" class="description">{{ content?.description }}</p>
    </div>

    <!-- Segment Name and Description -->
    <div class="segment-info">
      <div class="form-group">
        <label>Nome do Segmento *</label>
        <input
          v-model="segmentName"
          type="text"
          class="input"
          placeholder="Ex: VIPs de Eletrônicos"
          @input="handleSegmentNameChange"
        />
      </div>

      <div class="form-group">
        <label>Descrição (opcional)</label>
        <textarea
          v-model="segmentDescription"
          class="textarea"
          placeholder="Ex: Clientes que gastaram mais de R$10.000 em eletrônicos"
          rows="2"
          @input="handleSegmentDescriptionChange"
        />
      </div>
    </div>

    <!-- Groups -->
    <div class="groups-container">
      <div
        v-for="(group, groupIndex) in groups"
        :key="group.groupNumber"
        class="group-card"
      >
        <!-- Group Header -->
        <div class="group-header">
          <div class="group-title">
            <span class="group-badge">Grupo {{ group.groupNumber }}</span>
            <span class="group-logic-hint">Condições dentro do grupo: OR</span>
          </div>
          <button
            v-if="groups.length > 1"
            @click="removeGroup(groupIndex)"
            class="btn-remove"
            type="button"
          >
            ✕ Remover Grupo
          </button>
        </div>

        <!-- Conditions -->
        <div class="conditions-container">
          <div
            v-for="(condition, condIndex) in group.conditions"
            :key="`${group.groupNumber}-${condIndex}`"
            class="condition-row"
          >
            <!-- Field Selector -->
            <div class="condition-field">
              <label>Campo</label>
              <select
                v-model="condition.field"
                @change="handleFieldChange(groupIndex, condIndex)"
                class="select"
              >
                <option value="">Selecione um campo</option>
                <optgroup
                  v-for="category in fieldCategories"
                  :key="category.label"
                  :label="category.label"
                >
                  <option
                    v-for="field in category.fields"
                    :key="field.value"
                    :value="field.value"
                  >
                    {{ field.label }}
                  </option>
                </optgroup>
              </select>
            </div>

            <!-- Operator Selector -->
            <div v-if="condition.field" class="condition-operator">
              <label>Operador</label>
              <select
                v-model="condition.operator"
                @change="handleOperatorChange(groupIndex, condIndex)"
                class="select"
              >
                <option value="">Selecione</option>
                <option
                  v-for="op in getOperatorsForField(condition.field)"
                  :key="op.value"
                  :value="op.value"
                >
                  {{ op.label }}
                </option>
              </select>
            </div>

            <!-- Value Inputs (Dynamic based on type and operator) -->
            <div v-if="condition.operator" class="condition-value">
              <label>Valor</label>

              <!-- Numeric Fields -->
              <template v-if="getFieldType(condition.field) === 'numeric'">
                <div v-if="condition.operator === 'between'" class="value-between">
                  <input
                    v-model.number="condition.valueMin"
                    type="number"
                    class="input input-small"
                    placeholder="Mín"
                  />
                  <span class="separator">até</span>
                  <input
                    v-model.number="condition.valueMax"
                    type="number"
                    class="input input-small"
                    placeholder="Máx"
                  />
                </div>
                <input
                  v-else
                  v-model.number="condition.valueMin"
                  type="number"
                  class="input"
                  placeholder="Valor"
                />
              </template>

              <!-- Text Fields -->
              <input
                v-else-if="getFieldType(condition.field) === 'text'"
                v-model="condition.valueText"
                type="text"
                class="input"
                placeholder="Digite o texto"
              />

              <!-- Boolean Fields -->
              <select
                v-else-if="getFieldType(condition.field) === 'boolean'"
                v-model.number="condition.valueMin"
                class="select"
              >
                <option :value="1">Sim (Ativo)</option>
                <option :value="0">Não (Inativo)</option>
              </select>

              <!-- UUID Fields - Placeholder for now -->
              <input
                v-else-if="getFieldType(condition.field) === 'uuid'"
                v-model="condition.valueUuid"
                type="text"
                class="input"
                placeholder="ID do produto/categoria"
              />

              <!-- Date Fields -->
              <template v-else-if="getFieldType(condition.field) === 'date'">
                <input
                  v-model.number="condition.days"
                  type="number"
                  class="input"
                  placeholder="Dias"
                />
              </template>
            </div>

            <!-- Temporal Filter (if supported) -->
            <div
              v-if="condition.field && supportsTemporalFilter(condition.field)"
              class="condition-temporal"
            >
              <label>Período</label>
              <select v-model="condition.timeOperator" class="select">
                <option value="over_all_time">Desde sempre</option>
                <option value="in_the_last">Nos últimos X dias</option>
                <option value="between_dates">Entre datas</option>
              </select>

              <input
                v-if="condition.timeOperator === 'in_the_last'"
                v-model.number="condition.days"
                type="number"
                class="input input-small"
                placeholder="Dias"
              />

              <div
                v-if="condition.timeOperator === 'between_dates'"
                class="date-range"
              >
                <input
                  v-model="condition.startDate"
                  type="date"
                  class="input input-small"
                />
                <span class="separator">até</span>
                <input
                  v-model="condition.endDate"
                  type="date"
                  class="input input-small"
                />
              </div>
            </div>

            <!-- Remove Condition Button -->
            <button
              v-if="group.conditions.length > 1"
              @click="removeCondition(groupIndex, condIndex)"
              class="btn-remove-condition"
              type="button"
              title="Remover condição"
            >
              ✕
            </button>
          </div>

          <!-- Add Condition Button -->
          <button
            @click="addCondition(groupIndex)"
            class="btn-add-condition"
            type="button"
          >
            + Adicionar Condição (OR)
          </button>
        </div>

        <!-- AND Divider (except for last group) -->
        <div v-if="groupIndex < groups.length - 1" class="and-divider">
          <span class="and-badge">AND</span>
        </div>
      </div>

      <!-- Add Group Button -->
      <button @click="addGroup" class="btn-add-group" type="button">
        + Adicionar Grupo (AND)
      </button>
    </div>

    <!-- Preview Section -->
    <div v-if="content?.showPreview" class="preview-section">
      <button
        @click="handlePreview"
        :disabled="isLoadingPreview"
        class="btn-preview"
        type="button"
      >
        {{ isLoadingPreview ? 'Carregando...' : 'Preview: Ver Estimativa' }}
      </button>

      <div v-if="previewCount !== null" class="preview-result">
        <span class="preview-icon">👥</span>
        <span class="preview-text">
          {{ previewCount }} {{ previewCount === 1 ? 'cliente' : 'clientes' }} encontrados
        </span>
      </div>
    </div>

    <!-- Actions -->
    <div class="actions">
      <button
        @click="handleSave"
        :disabled="!canSave"
        class="btn-primary"
        type="button"
      >
        💾 Salvar Segmento
      </button>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch } from 'vue';

// Field Definitions
const FIELD_DEFINITIONS = {
  // v1 - Comportamento Básico
  frequency: { type: 'numeric', label: 'Frequência de Compras', temporal: true },
  total_value: { type: 'numeric', label: 'Valor Total Gasto', temporal: true },
  recencia: { type: 'numeric', label: 'Dias Desde Última Compra', temporal: true },

  // v2 - Demografia
  age: { type: 'numeric', label: 'Idade', temporal: false },
  birthday_period: { type: 'text', label: 'Período de Aniversário', temporal: false },
  gender: { type: 'text', label: 'Gênero', temporal: false },
  location_city: { type: 'text', label: 'Cidade', temporal: false },
  location_state: { type: 'text', label: 'Estado', temporal: false },
  opt_in_sms: { type: 'boolean', label: 'Opt-in SMS', temporal: false },
  opt_in_email: { type: 'boolean', label: 'Opt-in Email', temporal: false },
  opt_in_whatsapp: { type: 'boolean', label: 'Opt-in WhatsApp', temporal: false },

  // v2 - Cashback
  cashback_last_status: { type: 'text', label: 'Status do Último Cashback', temporal: false },
  cashback_last_value: { type: 'numeric', label: 'Valor do Último Cashback', temporal: false },
  cashback_expiry_date: { type: 'date', label: 'Data de Vencimento do Cashback', temporal: false },
  cashback_creation_date: { type: 'date', label: 'Data de Criação do Cashback', temporal: false },

  // v2 - RFM
  rfm_segment: { type: 'text', label: 'Segmento RFM', temporal: false },

  // v3 - Produtos
  product_id: { type: 'uuid', label: 'Produto Específico', temporal: true },
  product_name: { type: 'text', label: 'Nome do Produto', temporal: true },
  product_sku: { type: 'text', label: 'SKU do Produto', temporal: true },
  product_brand: { type: 'text', label: 'Marca', temporal: true },
  product_category_id: { type: 'uuid', label: 'Categoria (com hierarquia)', temporal: true },
  product_category_name: { type: 'text', label: 'Nome da Categoria', temporal: true },
  variation_color: { type: 'text', label: 'Cor', temporal: true },
  variation_size: { type: 'text', label: 'Tamanho', temporal: true },
  variation_material: { type: 'text', label: 'Material', temporal: true },
  product_purchase_count: { type: 'numeric', label: 'Quantidade de Compras', temporal: true },
  product_purchase_value: { type: 'numeric', label: 'Valor Total Gasto em Produtos', temporal: true },
  product_purchase_recency: { type: 'numeric', label: 'Dias Desde Última Compra de Produto', temporal: false },
};

const FIELD_CATEGORIES = [
  {
    label: '📊 Comportamento Básico',
    fields: [
      { value: 'frequency', label: 'Frequência de Compras' },
      { value: 'total_value', label: 'Valor Total Gasto' },
      { value: 'recencia', label: 'Dias Desde Última Compra' },
    ],
  },
  {
    label: '👤 Demografia',
    fields: [
      { value: 'age', label: 'Idade' },
      { value: 'birthday_period', label: 'Período de Aniversário' },
      { value: 'gender', label: 'Gênero' },
      { value: 'location_city', label: 'Cidade' },
      { value: 'location_state', label: 'Estado' },
      { value: 'opt_in_sms', label: 'Opt-in SMS' },
      { value: 'opt_in_email', label: 'Opt-in Email' },
      { value: 'opt_in_whatsapp', label: 'Opt-in WhatsApp' },
    ],
  },
  {
    label: '💰 Cashback',
    fields: [
      { value: 'cashback_last_status', label: 'Status do Último Cashback' },
      { value: 'cashback_last_value', label: 'Valor do Último Cashback' },
      { value: 'cashback_expiry_date', label: 'Data de Vencimento do Cashback' },
      { value: 'cashback_creation_date', label: 'Data de Criação do Cashback' },
    ],
  },
  {
    label: '📈 RFM',
    fields: [
      { value: 'rfm_segment', label: 'Segmento RFM' },
    ],
  },
  {
    label: '🛍️ Produtos',
    fields: [
      { value: 'product_id', label: 'Produto Específico' },
      { value: 'product_name', label: 'Nome do Produto' },
      { value: 'product_sku', label: 'SKU do Produto' },
      { value: 'product_brand', label: 'Marca' },
      { value: 'product_category_id', label: 'Categoria (com hierarquia)' },
      { value: 'product_category_name', label: 'Nome da Categoria' },
      { value: 'variation_color', label: 'Cor' },
      { value: 'variation_size', label: 'Tamanho' },
      { value: 'variation_material', label: 'Material' },
      { value: 'product_purchase_count', label: 'Quantidade de Compras' },
      { value: 'product_purchase_value', label: 'Valor Total Gasto em Produtos' },
      { value: 'product_purchase_recency', label: 'Dias Desde Última Compra de Produto' },
    ],
  },
];

export default {
  props: {
    uid: { type: String, required: true },
    content: { type: Object, required: true },
    /* wwEditor:start */
    wwEditorState: { type: Object, required: true },
    /* wwEditor:end */
  },
  emits: ['trigger-event'],
  setup(props, { emit }) {
    // State
    const segmentName = ref('');
    const segmentDescription = ref('');
    const groups = ref([createNewGroup(1)]);
    const previewCount = ref(null);
    const isLoadingPreview = ref(false);

    // Field definitions
    const fieldCategories = FIELD_CATEGORIES;

    // Internal variables
    const { value: segmentData, setValue: setSegmentData } = wwLib.wwVariable.useComponentVariable({
      uid: props.uid,
      name: 'segmentData',
      type: 'object',
      defaultValue: {},
    });

    // Computed
    const wrapperStyle = computed(() => ({
      '--primary-color': props.content?.primaryColor || '#007aff',
      '--background-color': props.content?.backgroundColor || '#ffffff',
      '--border-color': props.content?.borderColor || '#e0e0e0',
    }));

    const canSave = computed(() => {
      return (
        segmentName.value.trim().length > 0 &&
        groups.value.length > 0 &&
        groups.value.every(g => g.conditions.length > 0 && g.conditions.every(c => c.field && c.operator))
      );
    });

    // Helper Functions
    function createNewCondition() {
      return {
        field: '',
        operator: '',
        valueText: '',
        valueUuid: '',
        valueMin: null,
        valueMax: null,
        valueList: [],
        timeOperator: 'over_all_time',
        days: null,
        startDate: '',
        endDate: '',
      };
    }

    function createNewGroup(groupNumber) {
      return {
        groupNumber,
        conditions: [createNewCondition()],
      };
    }

    function getFieldType(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      return field?.type || 'text';
    }

    function getOperatorsForField(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      if (!field) return [];

      const operatorsByType = {
        numeric: [
          { value: '>=', label: 'Maior ou igual a' },
          { value: '<=', label: 'Menor ou igual a' },
          { value: '=', label: 'Igual a' },
          { value: 'between', label: 'Entre' },
        ],
        text: [
          { value: '=', label: 'Igual a' },
          { value: 'contains', label: 'Contém' },
          { value: 'starts_with', label: 'Começa com' },
        ],
        uuid: [{ value: '=', label: 'Igual a' }],
        boolean: [{ value: '=', label: 'Igual a' }],
        date: [
          { value: 'in_the_next', label: 'Nos próximos X dias' },
          { value: 'in_the_last', label: 'Nos últimos X dias' },
          { value: 'between_dates', label: 'Entre datas' },
        ],
      };

      return operatorsByType[field.type] || [];
    }

    function supportsTemporalFilter(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      return field?.temporal === true;
    }

    // Group/Condition Management
    function addGroup() {
      const newGroupNumber = groups.value.length + 1;
      groups.value.push(createNewGroup(newGroupNumber));
      updateSegmentData();
    }

    function removeGroup(index) {
      groups.value.splice(index, 1);
      // Renumber groups
      groups.value.forEach((group, idx) => {
        group.groupNumber = idx + 1;
      });
      updateSegmentData();
    }

    function addCondition(groupIndex) {
      groups.value[groupIndex].conditions.push(createNewCondition());
      updateSegmentData();
    }

    function removeCondition(groupIndex, conditionIndex) {
      groups.value[groupIndex].conditions.splice(conditionIndex, 1);
      updateSegmentData();
    }

    function handleFieldChange(groupIndex, condIndex) {
      const condition = groups.value[groupIndex].conditions[condIndex];
      // Reset operator and values when field changes
      condition.operator = '';
      condition.valueText = '';
      condition.valueUuid = '';
      condition.valueMin = null;
      condition.valueMax = null;
      condition.timeOperator = 'over_all_time';
      updateSegmentData();
    }

    function handleOperatorChange(groupIndex, condIndex) {
      const condition = groups.value[groupIndex].conditions[condIndex];
      // Reset values when operator changes
      condition.valueText = '';
      condition.valueUuid = '';
      condition.valueMin = null;
      condition.valueMax = null;
      updateSegmentData();
    }

    function handleSegmentNameChange() {
      updateSegmentData();
    }

    function handleSegmentDescriptionChange() {
      updateSegmentData();
    }

    // Update internal variable
    function updateSegmentData() {
      const payload = buildPayload();
      setSegmentData(payload);
    }

    // Build API Payload
    function buildPayload() {
      return {
        empresa: props.content?.empresaId,
        nome: segmentName.value,
        descricao: segmentDescription.value,
        groups: groups.value.map(group => ({
          groupNumber: group.groupNumber,
          conditions: group.conditions
            .filter(c => c.field && c.operator)
            .map(c => {
              const condition = {
                field: c.field,
                operator: c.operator,
              };

              // Add appropriate value fields
              if (c.valueText) condition.valueText = c.valueText;
              if (c.valueUuid) condition.valueUuid = c.valueUuid;
              if (c.valueMin !== null && c.valueMin !== undefined) condition.valueMin = c.valueMin;
              if (c.valueMax !== null && c.valueMax !== undefined) condition.valueMax = c.valueMax;
              if (c.valueList?.length > 0) condition.valueList = c.valueList;

              // Add temporal filters if supported
              if (supportsTemporalFilter(c.field)) {
                condition.timeOperator = c.timeOperator;
                if (c.timeOperator === 'in_the_last' && c.days) {
                  condition.days = c.days;
                }
                if (c.timeOperator === 'between_dates' && c.startDate && c.endDate) {
                  condition.startDate = c.startDate;
                  condition.endDate = c.endDate;
                }
              }

              return condition;
            }),
        })),
      };
    }

    // Preview
    async function handlePreview() {
      isLoadingPreview.value = true;
      previewCount.value = null;

      try {
        const payload = buildPayload();

        emit('trigger-event', {
          name: 'preview-requested',
          event: { payload }
        });

        // Simulate API call (replace with actual API call)
        await new Promise(resolve => setTimeout(resolve, 1000));
        previewCount.value = Math.floor(Math.random() * 500) + 1;
      } catch (error) {
        console.error('Preview error:', error);
      } finally {
        isLoadingPreview.value = false;
      }
    }

    // Save
    function handleSave() {
      if (!canSave.value) return;

      const payload = buildPayload();

      emit('trigger-event', {
        name: 'save-segment',
        event: { payload }
      });
    }

    // Watch for changes
    watch([segmentName, segmentDescription, groups], updateSegmentData, { deep: true });

    return {
      segmentName,
      segmentDescription,
      groups,
      previewCount,
      isLoadingPreview,
      fieldCategories,
      wrapperStyle,
      canSave,
      getFieldType,
      getOperatorsForField,
      supportsTemporalFilter,
      addGroup,
      removeGroup,
      addCondition,
      removeCondition,
      handleFieldChange,
      handleOperatorChange,
      handleSegmentNameChange,
      handleSegmentDescriptionChange,
      handlePreview,
      handleSave,
    };
  },
};
</script>

<style lang="scss" scoped>
.segmentation-builder {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
  background-color: var(--background-color);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.builder-header {
  margin-bottom: 32px;

  .title {
    margin: 0 0 8px 0;
    font-size: 28px;
    font-weight: 700;
    color: #1a1a1a;
  }

  .description {
    margin: 0;
    font-size: 14px;
    color: #666;
  }
}

.segment-info {
  margin-bottom: 32px;
  padding: 20px;
  background: #f9f9f9;
  border-radius: 8px;
}

.form-group {
  margin-bottom: 16px;

  &:last-child {
    margin-bottom: 0;
  }

  label {
    display: block;
    margin-bottom: 8px;
    font-size: 14px;
    font-weight: 600;
    color: #333;
  }
}

.input,
.select,
.textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
  transition: border-color 0.2s;

  &:focus {
    outline: none;
    border-color: var(--primary-color);
  }
}

.textarea {
  resize: vertical;
}

.input-small {
  width: auto;
  min-width: 100px;
}

.groups-container {
  margin-bottom: 32px;
}

.group-card {
  margin-bottom: 24px;
  padding: 20px;
  background: #fff;
  border: 2px solid var(--border-color);
  border-radius: 12px;
  position: relative;
}

.group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.group-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.group-badge {
  display: inline-block;
  padding: 6px 12px;
  background: var(--primary-color);
  color: #fff;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
}

.group-logic-hint {
  font-size: 12px;
  color: #666;
  font-style: italic;
}

.conditions-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.condition-row {
  display: grid;
  grid-template-columns: 2fr 1.5fr 2fr 1.5fr auto;
  gap: 12px;
  align-items: end;
  padding: 16px;
  background: #f9f9f9;
  border-radius: 8px;
  position: relative;
}

.condition-field,
.condition-operator,
.condition-value,
.condition-temporal {
  display: flex;
  flex-direction: column;
  gap: 6px;

  label {
    font-size: 12px;
    font-weight: 600;
    color: #555;
  }
}

.value-between,
.date-range {
  display: flex;
  align-items: center;
  gap: 8px;

  .separator {
    font-size: 12px;
    color: #666;
  }
}

.btn-remove-condition {
  padding: 8px 12px;
  background: #ff3b30;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 16px;
  line-height: 1;
  transition: background 0.2s;

  &:hover {
    background: #e02020;
  }
}

.btn-add-condition {
  margin-top: 8px;
  padding: 10px 16px;
  background: #fff;
  color: var(--primary-color);
  border: 2px dashed var(--primary-color);
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.2s;

  &:hover {
    background: rgba(0, 122, 255, 0.05);
  }
}

.btn-remove {
  padding: 8px 16px;
  background: #ff3b30;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  transition: background 0.2s;

  &:hover {
    background: #e02020;
  }
}

.and-divider {
  display: flex;
  justify-content: center;
  margin: 24px 0;
}

.and-badge {
  display: inline-block;
  padding: 8px 20px;
  background: #34c759;
  color: #fff;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.btn-add-group {
  width: 100%;
  padding: 14px;
  background: #fff;
  color: #34c759;
  border: 2px dashed #34c759;
  border-radius: 8px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 600;
  transition: all 0.2s;

  &:hover {
    background: rgba(52, 199, 89, 0.05);
  }
}

.preview-section {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
  padding: 20px;
  background: #f0f0f0;
  border-radius: 8px;
}

.btn-preview {
  padding: 12px 24px;
  background: #5856d6;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: background 0.2s;

  &:hover:not(:disabled) {
    background: #4745b8;
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
}

.preview-result {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: #fff;
  border-radius: 6px;
  font-size: 15px;
  font-weight: 600;
  color: #333;
}

.preview-icon {
  font-size: 20px;
}

.actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn-primary {
  padding: 14px 32px;
  background: var(--primary-color);
  color: #fff;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  transition: all 0.2s;

  &:hover:not(:disabled) {
    background: #0056b3;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none;
  }
}

/* Responsive */
@media (max-width: 1024px) {
  .condition-row {
    grid-template-columns: 1fr;
    gap: 12px;
  }
}

@media (max-width: 768px) {
  .segmentation-builder {
    padding: 16px;
  }

  .builder-header .title {
    font-size: 24px;
  }

  .group-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
}
</style>
