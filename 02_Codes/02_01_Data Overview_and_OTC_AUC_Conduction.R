#install.packages("tidyverse")

#read data
wd <- "/project/rrg-oespinga/oespinga/OAI/ClinicalData/CompleteData_ASCII/"
min8=read.table(paste0(wd,"/Acceldatabymin08.txt"), sep="|", header=T) 
min6=read.table(paste0(wd,"/Acceldatabymin06.txt"), sep="|", header=T) 

#preview of data
summary(min8)
summary(min6)

length(unique(min8$ID))
length(unique(min6$ID))

library(dplyr)
library(ggplot2)

#look at a particular ID and single day
#get the t vs VM(t) plot
target_id <- "9000099"
min8_target_id <- min8[min8$ID == target_id, ]
days_summary <- min8 %>%
  filter(ID == target_id) %>%
  group_by(V08PAStudyDay) %>%
  summarise(
    n_minutes = n(),
    n_valid   = sum(V08SuspectMinute == 0, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(V08PAStudyDay)
days_summary
 
target_day <- 1086
df1 <- min8 %>%
  filter(ID == target_id, V08PAStudyDay == target_day) %>%
  mutate(
    minute = V08MinSequence - 1,
    hour = minute / 60
  )

ggplot(df1, aes(x = hour, y = V08MINCnt)) +
  geom_line(linewidth = 0.3) +
  labs(
    title = paste("24-hour accelerometer data | ID =", target_id, "| Day =", target_day),
    x = "Hour of day",
    y = "VM(t) (V08MINCnt)"
  ) +
  scale_x_continuous(breaks = 0:24) +
  theme_bw()

#OTC
df1_valid <- df1 %>%
  filter(V08SuspectMinute == 0) %>%
  filter(!is.na(V08MINCnt))

vm <- df1_valid$V08MINCnt
Tn <- length(vm)

Cmax <- 30000
c_grid <- seq(0, Cmax, by = 100)

vm_cap <- pmin(pmax(vm, 0), Cmax)
bin_id <- floor(vm_cap / 100) + 1L               

counts_per_bin <- tabulate(bin_id, nbins = length(c_grid))
otc <- rev(cumsum(rev(counts_per_bin))) / Tn      

otc_df1 <- data.frame(
  ID = target_id,
  V08PAStudyDay = target_day,
  c = c_grid,
  otc = otc,
  c_over_100 = c_grid / 100
)


head(otc_df1)
tail(otc_df1)

ggplot(otc_df1, aes(x = c_over_100, y = otc)) +
  geom_line(linewidth = 0.35) +
  geom_point(size = 1.1) +
  labs(
    title = paste("OTC Construction | ID =", target_id, "| Day =", target_day),
    x = "VM Counts/100",
    y = "P(VM(t) >= c)"
  ) +
  theme_bw()

#look at a particular ID and combining all days
target_id <- "9000099"

df_cont <- min8 %>%
  filter(ID == target_id) %>%
  mutate(
    minute = V08MinSequence - 1,
    hour_in_day = minute / 60
  ) %>%
  arrange(V08PAStudyDay, minute) %>%
  mutate(
    day_index = dense_rank(V08PAStudyDay) - 1,  
    t_hour = day_index * 24 + hour_in_day
  )


day_labels <- df_cont %>%
  distinct(day_index, V08PAStudyDay) %>%
  mutate(
    t_hour = day_index * 24,
    label = paste0(
      t_hour, "\n",
      "StudyDay ", V08PAStudyDay
    )
  )

ggplot(df_cont, aes(x = t_hour, y = V08MINCnt)) +
  geom_line(linewidth = 0.25) +
  geom_vline(
    data = day_labels,
    aes(xintercept = t_hour),
    linetype = "dashed",
    linewidth = 0.1
  ) +
  scale_x_continuous(
    breaks = day_labels$t_hour,
    labels = day_labels$label
  ) +
  labs(
    title = paste("Continuous accelerometer VM(t) across days | ID =", target_id),
    x = "Time (hours, continuous) + original V08PAStudyDay",
    y = "VM(t) (V08MINCnt)"
  ) +
  theme_bw()


df_all_valid <- df_cont %>%
  filter(V08SuspectMinute == 0, !is.na(V08MINCnt))

vm <- df_all_valid$V08MINCnt
Tn <- length(vm)

Cmax <- 30000
c_grid <- seq(0, Cmax, by = 100)

vm_cap <- pmin(pmax(vm, 0), Cmax)
bin_id <- floor(vm_cap / 100) + 1L
counts_per_bin <- tabulate(bin_id, nbins = length(c_grid))
otc <- rev(cumsum(rev(counts_per_bin))) / Tn

otc_df <- data.frame(
  ID = target_id,
  c = c_grid,
  otc = otc,
  c_over_100 = c_grid / 100,
  n_minutes = Tn
)

ggplot(otc_df, aes(x = c_over_100, y = otc)) +
  geom_line(linewidth = 0.4) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(
    title = paste("Occupation Time Curve (OTC) | ID =", target_id),
    subtitle = paste("All available days | minutes =", Tn),
    x = "Activity intensity threshold (VM / 100)",
    y = expression(P(VM(t) >= c))
  ) +
  theme_bw()

#AUC
delta_c <- diff(otc_df$c)
AUC <- otc_df$otc[-1] * delta_c
auc_df <- data.frame(
  ID = target_id,
  j = seq_along(AUC),
  c_left = otc_df$c[-length(otc_df$c)],
  c_right = otc_df$c[-1],
  AUC = AUC
)
head(auc_df)
ggplot(auc_df, aes(x = j, y = AUC)) +
  geom_line(linewidth = 0.4) +
  labs(
    title = paste("AUC features derived from OTC | ID =", target_id),
    x = "Activity intensity interval index j",
    y = expression(A[j])
  ) +
  theme_bw()

library(dplyr)
library(purrr)
library(ggplot2)
library(pheatmap)

set.seed(123)

n_subject <- 50
bin_width <- 100

Cmax <- as.numeric(quantile(min8$V08MINCnt, 0.995, na.rm = TRUE))
c_grid <- seq(0, Cmax, by = bin_width)
J <- length(c_grid) - 1

ids <- unique(min8$ID)
sub_ids <- sample(
  ids,
  size = min(n_subject, length(ids)),
  replace = FALSE
)

compute_auc_one_id <- function(id, dat, c_grid, bin_width) {
  
  df_valid <- dat %>%
    filter(
      ID == id,
      V08SuspectMinute == 0,
      !is.na(V08MINCnt)
    )
  
  vm <- df_valid$V08MINCnt
  Tn <- length(vm)
  
  if (Tn == 0) {
    return(rep(NA_real_, length(c_grid) - 1))
  }
  
  vm_cap <- pmin(pmax(vm, 0), max(c_grid))
  bin_id <- floor(vm_cap / bin_width) + 1L
  counts <- tabulate(bin_id, nbins = length(c_grid))
  
  otc <- rev(cumsum(rev(counts))) / Tn
  delta_c <- diff(c_grid)
  
  auc <- otc[-1] * delta_c
  return(auc)
}


AUC_mat <- map_dfr(
  sub_ids,
  ~ as.data.frame(t(compute_auc_one_id(.x, min8, c_grid, bin_width)))
)

AUC_mat <- as.matrix(AUC_mat)
rownames(AUC_mat) <- sub_ids
colnames(AUC_mat) <- paste0("AUC_", seq_len(ncol(AUC_mat)))

cat("AUC_mat dimension:", dim(AUC_mat), "\n")

keep_rows <- rowSums(!is.na(AUC_mat)) > 0
AUC_mat <- AUC_mat[keep_rows, , drop = FALSE]

cat("After removing NA subjects:", dim(AUC_mat), "\n")


sd_cols <- apply(AUC_mat, 2, sd, na.rm = TRUE)
keep_cols <- sd_cols > 0

AUC_mat2 <- AUC_mat[, keep_cols, drop = FALSE]

cat("Kept columns:", sum(keep_cols), "out of", length(keep_cols), "\n")
cat("Proportion zero-variance columns:", mean(!keep_cols), "\n")


cor_AUC2 <- cor(AUC_mat2, use = "pairwise.complete.obs")

pheatmap(
  cor_AUC2,
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  show_rownames = FALSE,
  show_colnames = FALSE,
  main = "Correlation matrix of AUC features"
)


J2 <- ncol(AUC_mat2)
max_lag <- min(10, J2 - 1)

corr_lag <- sapply(1:max_lag, function(k) {
  mean(diag(cor_AUC2[1:(J2 - k), (1 + k):J2]), na.rm = TRUE)
})

corr_df <- data.frame(
  lag = 1:max_lag,
  corr = corr_lag
)

print(corr_df)

ggplot(corr_df, aes(x = lag, y = corr)) +
  geom_line() +
  geom_point() +
  ylim(0, 1) +
  labs(
    title = "Average correlation between AUC_j and AUC_{j+k}",
    x = "Lag k",
    y = "Average correlation"
  ) +
  theme_bw()

if (J2 >= 6) {
  cat("Avg corr(AUC_j, AUC_{j+1}):", corr_df$corr[corr_df$lag == 1], "\n")
  cat("Avg corr(AUC_j, AUC_{j+5}):", corr_df$corr[corr_df$lag == 5], "\n")
}
#
library(dplyr)
library(purrr)

set.seed(123)


n_subject <- 200       
bin_width <- 100
Cmax <- 30000
c_grid <- seq(0, Cmax, by = bin_width)   # length = 301 -> J = 300
J <- length(c_grid) - 1


ids <- unique(min8$ID)
sub_ids <- sample(ids, size = min(n_subject, length(ids)), replace = FALSE)


compute_auc_one_id <- function(id, dat, c_grid, bin_width) {
  
  df_valid <- dat %>%
    filter(ID == id,
           V08SuspectMinute == 0,
           !is.na(V08MINCnt))
  
  vm <- df_valid$V08MINCnt
  Tn <- length(vm)
  
  if (Tn == 0) return(rep(NA_real_, length(c_grid) - 1))
  
  vm_cap <- pmin(pmax(vm, 0), max(c_grid))
  bin_id <- floor(vm_cap / bin_width) + 1L
  counts <- tabulate(bin_id, nbins = length(c_grid))
  
  otc <- rev(cumsum(rev(counts))) / Tn
  delta_c <- diff(c_grid)
  
  auc <- otc[-1] * delta_c
  auc
}


AUC_mat <- map_dfr(
  sub_ids,
  ~ as.data.frame(t(compute_auc_one_id(.x, min8, c_grid, bin_width)))
)

AUC_mat <- as.matrix(AUC_mat)
rownames(AUC_mat) <- sub_ids

keep_rows <- rowSums(!is.na(AUC_mat)) > 0
AUC_mat <- AUC_mat[keep_rows, , drop = FALSE]

sd_cols <- apply(AUC_mat, 2, sd, na.rm = TRUE)
keep_cols <- sd_cols > 0
AUC_mat2 <- AUC_mat[, keep_cols, drop = FALSE]

cat("Subjects used:", nrow(AUC_mat2), "\n")
cat("AUC columns kept:", ncol(AUC_mat2), "out of", ncol(AUC_mat), "\n")


cor_AUC <- cor(AUC_mat2, use = "pairwise.complete.obs")

mean_corr_lag <- function(cor_mat, k) {
  J2 <- ncol(cor_mat)
  if (k >= J2) return(NA_real_)
  mean(diag(cor_mat[1:(J2-k), (1+k):J2]), na.rm = TRUE)
}

c1  <- mean_corr_lag(cor_AUC, 1)
c5  <- mean_corr_lag(cor_AUC, 5)
c10 <- mean_corr_lag(cor_AUC, 10)

cat(sprintf("Mean pairwise correlations (J=300):\n"))
cat(sprintf("cor(Aj, Aj+1)  = %.3f\n", c1))
cat(sprintf("cor(Aj, Aj+5)  = %.3f\n", c5))
cat(sprintf("cor(Aj, Aj+10) = %.3f\n", c10))

