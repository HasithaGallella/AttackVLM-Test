# #!/bin/bash


python _train_adv_img_query.py \
    --data_path '../_output_text/blip2_trans' \
    --text_path '../_output_text/blip2_trans.txt' \
    --output_path 'blip2_trans_query' \
    --model_name blip2_opt \
    --model_type pretrain_opt2.7b \
    --batch_size 1 \
    --num_samples 10000 \
    --steps 8 \
    --sigma 8 \
    --delta 'zero' \
    --num_query 100 \
    --num_sub_query 50 \
    --wandb \
    --wandb_project_name blip2 \
    --wandb_run_name trans+query