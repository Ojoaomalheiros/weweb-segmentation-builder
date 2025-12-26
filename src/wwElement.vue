<template>
  <div class="segmentation-page">
    <!-- Top Header -->
    <div class="page-header">
      <h1 class="page-title">Criar Segmento</h1>
      <div class="header-actions">
        <button @click="handleCancel" class="btn-secondary" type="button">
          Cancelar
        </button>
        <button
          @click="handleSave"
          :disabled="!canSave"
          class="btn-primary"
          type="button"
        >
          Salvar segmento
        </button>
      </div>
    </div>

    <!-- Content Area -->
    <div class="page-content">
      <!-- Section Header -->
      <div class="section-card">
        <h2 class="section-title">Construtor de segmento</h2>
        <p class="section-description">
          Os segmentos permitem rastrear e analisar clientes que atendem a certos critérios
        </p>

        <!-- Name and Description Row -->
        <div class="fields-row">
          <div class="field-group">
            <label class="field-label">Nome *</label>
            <input
              v-model="segmentName"
              type="text"
              class="field-input"
              placeholder="Digite o nome do segmento"
              @input="handleSegmentNameChange"
            />
          </div>

          <div class="field-group">
            <label class="field-label">Descrição</label>
            <input
              v-model="segmentDescription"
              type="text"
              class="field-input"
              placeholder="Digite a descrição do segmento"
              @input="handleSegmentDescriptionChange"
            />
          </div>
        </div>

        <!-- Builder Title -->
        <h3 class="builder-title">Criar um segmento para clientes que:</h3>

        <!-- Groups and Conditions -->
        <div class="conditions-area">
          <template v-for="(group, groupIndex) in groups" :key="group.groupNumber">
            <!-- Conditions in this group -->
            <div
              v-for="(condition, condIndex) in group.conditions"
              :key="`${group.groupNumber}-${condIndex}`"
              class="condition-item"
            >
              <div class="condition-content">
                <!-- Field Selector -->
                <select
                  v-model="condition.field"
                  @change="handleFieldChange(groupIndex, condIndex)"
                  class="select-field"
                >
                  <option value="">Selecione o Critério</option>
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

                <!-- Operator -->
                <select
                  v-if="condition.field"
                  v-model="condition.operator"
                  @change="handleOperatorChange(groupIndex, condIndex)"
                  class="select-field"
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

                <!-- Value Inputs -->
                <template v-if="condition.operator">
                  <!-- Numeric between -->
                  <template v-if="getFieldType(condition.field) === 'numeric' && condition.operator === 'between'">
                    <input
                      v-model.number="condition.valueMin"
                      type="number"
                      class="input-small"
                      placeholder="Mín"
                    />
                    <input
                      v-model.number="condition.valueMax"
                      type="number"
                      class="input-small"
                      placeholder="Máx"
                    />
                  </template>

                  <!-- Numeric single -->
                  <input
                    v-else-if="getFieldType(condition.field) === 'numeric'"
                    v-model.number="condition.valueMin"
                    type="number"
                    class="input-small"
                    placeholder="30"
                  />

                  <!-- Text -->
                  <input
                    v-else-if="getFieldType(condition.field) === 'text'"
                    v-model="condition.valueText"
                    type="text"
                    class="input-field"
                    placeholder="Digite"
                  />

                  <!-- Boolean -->
                  <select
                    v-else-if="getFieldType(condition.field) === 'boolean'"
                    v-model.number="condition.valueMin"
                    class="select-field"
                  >
                    <option :value="1">Sim</option>
                    <option :value="0">Não</option>
                  </select>

                  <!-- UUID -->
                  <input
                    v-else-if="getFieldType(condition.field) === 'uuid'"
                    v-model="condition.valueUuid"
                    type="text"
                    class="input-field"
                    placeholder="ID"
                  />

                  <!-- Date -->
                  <input
                    v-else-if="getFieldType(condition.field) === 'date'"
                    v-model.number="condition.days"
                    type="number"
                    class="input-small"
                    placeholder="Dias"
                  />
                </template>

                <!-- Temporal Filter -->
                <select
                  v-if="condition.field && supportsTemporalFilter(condition.field)"
                  v-model="condition.timeOperator"
                  class="select-field"
                >
                  <option value="over_all_time">desde sempre</option>
                  <option value="in_the_last">nos últimos X dias</option>
                  <option value="between_dates">entre datas</option>
                </select>

                <!-- Days for temporal -->
                <template v-if="condition.timeOperator === 'in_the_last'">
                  <input
                    v-model.number="condition.days"
                    type="number"
                    class="input-small"
                    placeholder="30"
                  />
                  <span class="text-label">dias</span>
                </template>

                <!-- Date range for temporal -->
                <template v-if="condition.timeOperator === 'between_dates'">
                  <input
                    v-model="condition.startDate"
                    type="date"
                    class="input-small"
                  />
                  <input
                    v-model="condition.endDate"
                    type="date"
                    class="input-small"
                  />
                </template>

                <!-- Delete Button -->
                <button
                  @click="removeCondition(groupIndex, condIndex)"
                  class="btn-delete"
                  type="button"
                  title="Remover"
                >
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M2 4H14M12.6667 4V13.3333C12.6667 14 12 14.6667 11.3333 14.6667H4.66667C4 14.6667 3.33333 14 3.33333 13.3333V4M5.33333 4V2.66667C5.33333 2 6 1.33333 6.66667 1.33333H9.33333C10 1.33333 10.6667 2 10.6667 2.66667V4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M6.66667 7.33334V11.3333" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M9.33333 7.33334V11.3333" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </button>
              </div>

              <!-- OU divider -->
              <div v-if="condIndex < group.conditions.length - 1" class="divider-ou">
                OU
              </div>
            </div>

            <!-- Add OU button -->
            <button
              @click="addCondition(groupIndex)"
              class="btn-add-condition"
              type="button"
            >
              <span class="plus-icon">+</span> OU
            </button>

            <!-- E divider -->
            <div v-if="groupIndex < groups.length - 1" class="divider-e">
              E
            </div>
          </template>

          <!-- Add E button -->
          <button @click="addGroup" class="btn-add-group" type="button">
            <span class="plus-icon">+</span> E
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch } from 'vue';

// Field Definitions
const FIELD_DEFINITIONS = {
  // v1 - Comportamento Básico
  frequency: { type: 'numeric', label: 'Número de pedidos', temporal: true },
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
    label: '📊 Comportamento',
    fields: [
      { value: 'frequency', label: 'Número de pedidos' },
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
    const segmentName = ref('');
    const segmentDescription = ref('');
    const groups = ref([createNewGroup(1)]);

    const fieldCategories = FIELD_CATEGORIES;

    const { value: segmentData, setValue: setSegmentData } = wwLib.wwVariable.useComponentVariable({
      uid: props.uid,
      name: 'segmentData',
      type: 'object',
      defaultValue: {},
    });

    const canSave = computed(() => {
      return (
        segmentName.value.trim().length > 0 &&
        groups.value.length > 0 &&
        groups.value.every(g => g.conditions.length > 0 && g.conditions.every(c => c.field && c.operator))
      );
    });

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
          { value: '>=', label: 'maior ou igual a' },
          { value: '<=', label: 'menor ou igual a' },
          { value: '=', label: 'igual a' },
          { value: 'between', label: 'entre' },
        ],
        text: [
          { value: '=', label: 'igual a' },
          { value: 'contains', label: 'contém' },
          { value: 'starts_with', label: 'começa com' },
        ],
        uuid: [{ value: '=', label: 'igual a' }],
        boolean: [{ value: '=', label: 'é' }],
        date: [
          { value: 'in_the_next', label: 'nos próximos' },
          { value: 'in_the_last', label: 'nos últimos' },
          { value: 'between_dates', label: 'entre datas' },
        ],
      };

      return operatorsByType[field.type] || [];
    }

    function supportsTemporalFilter(fieldName) {
      const field = FIELD_DEFINITIONS[fieldName];
      return field?.temporal === true;
    }

    function addGroup() {
      const newGroupNumber = groups.value.length + 1;
      groups.value.push(createNewGroup(newGroupNumber));
      updateSegmentData();
    }

    function removeGroup(index) {
      if (groups.value.length <= 1) return;
      groups.value.splice(index, 1);
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
      const group = groups.value[groupIndex];
      if (group.conditions.length <= 1) {
        removeGroup(groupIndex);
      } else {
        group.conditions.splice(conditionIndex, 1);
        updateSegmentData();
      }
    }

    function handleFieldChange(groupIndex, condIndex) {
      const condition = groups.value[groupIndex].conditions[condIndex];
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

    function updateSegmentData() {
      const payload = buildPayload();
      setSegmentData(payload);
    }

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

              if (c.valueText) condition.valueText = c.valueText;
              if (c.valueUuid) condition.valueUuid = c.valueUuid;
              if (c.valueMin !== null && c.valueMin !== undefined) condition.valueMin = c.valueMin;
              if (c.valueMax !== null && c.valueMax !== undefined) condition.valueMax = c.valueMax;
              if (c.valueList?.length > 0) condition.valueList = c.valueList;

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

    function handleSave() {
      if (!canSave.value) return;
      const payload = buildPayload();
      emit('trigger-event', {
        name: 'save-segment',
        event: { payload }
      });
    }

    function handleCancel() {
      emit('trigger-event', {
        name: 'cancel',
        event: {}
      });
    }

    watch([segmentName, segmentDescription, groups], updateSegmentData, { deep: true });

    return {
      segmentName,
      segmentDescription,
      groups,
      fieldCategories,
      canSave,
      getFieldType,
      getOperatorsForField,
      supportsTemporalFilter,
      addGroup,
      addCondition,
      removeCondition,
      handleFieldChange,
      handleOperatorChange,
      handleSegmentNameChange,
      handleSegmentDescriptionChange,
      handleSave,
      handleCancel,
    };
  },
};
</script>

<style lang="scss" scoped>
* {
  box-sizing: border-box;
}

.segmentation-page {
  min-height: 100vh;
  background-color: #fafafa;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background-color: #ffffff;
  border-bottom: 1px solid #e5e7eb;
}

.page-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #000000;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.btn-secondary {
  padding: 8px 20px;
  background: #ffffff;
  color: #000000;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s;

  &:hover {
    background: #f9fafb;
    border-color: #9ca3af;
  }
}

.btn-primary {
  padding: 8px 20px;
  background: #5b21b6;
  color: #ffffff;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s;

  &:hover:not(:disabled) {
    background: #4c1d95;
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.page-content {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.section-card {
  background: #ffffff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.section-title {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #000000;
}

.section-description {
  margin: 0 0 24px 0;
  font-size: 13px;
  color: #6b7280;
  line-height: 1.5;
}

.fields-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 32px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-size: 13px;
  font-weight: 500;
  color: #374151;
}

.field-input {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  color: #000000;
  background: #ffffff;

  &::placeholder {
    color: #9ca3af;
  }

  &:focus {
    outline: none;
    border-color: #5b21b6;
    box-shadow: 0 0 0 3px rgba(91, 33, 182, 0.1);
  }
}

.builder-title {
  margin: 0 0 16px 0;
  font-size: 14px;
  font-weight: 500;
  color: #000000;
}

.conditions-area {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.condition-item {
  margin-bottom: 8px;
}

.condition-content {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.select-field,
.input-field,
.input-small {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 13px;
  color: #000000;
  background: #ffffff;

  &:focus {
    outline: none;
    border-color: #5b21b6;
    box-shadow: 0 0 0 3px rgba(91, 33, 182, 0.1);
  }
}

.select-field {
  min-width: 160px;
  background-image: url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%239ca3af' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 32px;
  appearance: none;
}

.input-field {
  flex: 1;
  min-width: 120px;
}

.input-small {
  width: 80px;
}

.text-label {
  font-size: 13px;
  color: #6b7280;
}

.btn-delete {
  padding: 6px;
  background: transparent;
  color: #dc2626;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;
  margin-left: auto;

  &:hover {
    background: #fee2e2;
  }

  svg {
    width: 16px;
    height: 16px;
  }
}

.divider-ou {
  padding: 8px 0 8px 12px;
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.divider-e {
  padding: 12px 0 12px 0;
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.btn-add-condition,
.btn-add-group {
  padding: 10px 16px;
  background: transparent;
  color: #5b21b6;
  border: 2px dashed #c4b5fd;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  text-align: left;
  width: fit-content;
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 8px;

  &:hover {
    background: #f5f3ff;
    border-color: #5b21b6;
  }

  .plus-icon {
    font-size: 16px;
    font-weight: 600;
  }
}

/* Responsive */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .fields-row {
    grid-template-columns: 1fr;
  }

  .condition-content {
    flex-direction: column;
    align-items: stretch;

    .select-field,
    .input-field {
      width: 100%;
    }
  }

  .btn-delete {
    align-self: flex-end;
  }
}
</style>
