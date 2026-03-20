package com.alumni.app.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DashboardSummaryDTO {
    private long pendingCount;
    private long acceptedCount;
    private long rejectedCount;
}
