<h1 align='center' style="text-align:center; font-weight:bold; font-size:2.0em;letter-spacing:2.0px;">
                On Evaluating Adversarial Robustness of </br> Large Vision-Language Models </h1>
<p align='center' style="text-align:center;font-size:1.25em;">
    <a href="https://scholar.google.com/citations?user=kQA0x9UAAAAJ&hl=en" target="_blank" style="text-decoration: none;">Yunqing Zhao<sup>*1</sup></a>&nbsp;,&nbsp;
    <a href="https://p2333.github.io/" target="_blank" style="text-decoration: none;">Tianyu Pang<sup>*2&#8224</sup></a>&nbsp;,&nbsp;
    <a href="https://duchao0726.github.io/" target="_blank" style="text-decoration: none;">Chao Du<sup>2&#8224</sup></a>&nbsp;,&nbsp;
    <a href="https://ml.cs.tsinghua.edu.cn/~xiaoyang/" target="_blank" style="text-decoration: none;">Xiao Yang <sup>3</sup> </a>&nbsp;,&nbsp;
    <a href="https://zhenxuan00.github.io/" target="_blank" style="text-decoration: none;">Chongxuan Li <sup>4</sup> </a><br/>
    <a href="https://sites.google.com/site/mancheung0407/" target="_blank" style="text-decoration: none;">Ngai&#8209;Man Cheung<sup>1&#8224</sup></a>&nbsp;,&nbsp; 
    <a href="https://linmin.me/" target="_blank" style="text-decoration: none;">Min Lin<sup>2</sup></a> &nbsp;&nbsp;&nbsp;&nbsp; <sup>*</sup>Equal Contribution
    <br/> 
<sup>1</sup>Singapore University of Technology and Design (SUTD)<br/> 
<sup>2</sup>Sea AI Lab (SAIL), Singapore <br/>
<sup>3</sup>Tsinghua University &nbsp;&nbsp;
<sup>4</sup>Renmin University of China
</p>

<p align='center';>
<b>
<em>arXiv-Preprint, 2023</em> <br>
</b>
</p>

<p align='center' style="text-align:center;font-size:2.5 em;">
<b>
    <a href="" target="_blank" style="text-decoration: none;">Project Page</a>&nbsp;/&nbsp;
    <a href="" target="_blank" style="text-decoration: none;">Slides</a>&nbsp;/&nbsp;
    <a href="" target="_blank" style="text-decoration: none;">arXiv</a>&nbsp;/&nbsp;
    <a href="https://drive.google.com/drive/folders/118MTDLEw0YefC-Z0eGllKNAx_aavBrFP?usp=sharing" target="_blank" style="text-decoration: none;">Data Repository</a>&nbsp;
</b>
</p>


----------------------------------------------------------------------

### TL, DR: 
```
In this research, we evaluate the adversarial robustness of recent large vision-language models (VLMs), under the most realistic and challenging setting with threat model of black-box access and targeted goal.

Our proposed method aims for the targeted response generation over large VLMs such as MiniGPT-4, LLaVA, Unidiffuser, BLIP/2, Img2Prompt, etc.

In other words, we mislead and let the VLMs say what you want, regardless of the content of the input images.
```

![Teaser image](./assets/teaser_1.jpg)
![Teaser image](./assets/teaser_2.jpg)

# Requirements

- Platform: Linux
- Hardware: A100 PCIe 40G
- lmdb, tqdm
- wandb, torchvision, etc.

As we apply [Stable Diffusion](https://github.com/CompVis/stable-diffusion) for targeted image generation, we init our [conda](https://docs.conda.io/en/latest/) environment following [Latent Diffusion Models](https://github.com/CompVis/latent-diffusion). Alternatively, a suitable conda environment named `ldm` can be created and activated with:
```
conda env create -f environment.yaml
conda activate ldm
```

Note that for different victim models, we will follow their official implementations and conda environments.


# Targeted Image Generation
![Teaser image](./assets/teaser_3.jpg)
As discussed in our paper, to achieve a flexible targeted attack, we leverage a pretrained text-to-image model to generate an targetd image given a single caption as the targeted text. Consequently, in this way you can specify the targeted caption for attack by yourself! 

We use [Stable Diffusion](https://github.com/CompVis/stable-diffusion), [DALL-E](https://openai.com/blog/dall-e-now-available-without-waitlist) or [Midjourney](https://www.midjourney.com/app/) as the text-to-image generators in our experiments. Here, we use Stable Diffusion for demonstration (thanks for open-sourcing!). 

## Prepare the scripts

```
git clone https://github.com/CompVis/stable-diffusion.git
cd stable-diffusion
```
then, prepare the full targeted captions from [MS-COCO](https://cocodataset.org/#home), or download our processed and cleaned version from here:
```
https://drive.google.com/file/d/19tT036LBvqYonzI7PfU9qVi3jVGApKrg/view?usp=sharing
```
and move it to ```./stable-diffusion/```. In experiments, one can randomly sample a subset of COCO captions (e.g., `10`, `100`, `1K`, `10K`, `50K`) for the adversarial attack. For example, lets assume we have randomly sampled `10K` COCO captions as our targeted text $\boldsymbol{c}_\text{tar}$ and stored them in the following file:
```
https://drive.google.com/file/d/1e5W3Yim7ZJRw3_C64yqVZg_Na7dOawaF/view?usp=sharing
```

## Generate the targeted images
The targeted images $\boldsymbol{h}_\xi(\boldsymbol{c}_\text{tar})$ can be obtained via Stable Diffusion by reading text prompt from the sampled COCO captions, with the script below (note that hyperparameters can be adjusted with your preference):

```
CUDA_VISIBLE_DEVICES=0 \
python ./scripts/txt2img.py --ddim_eta 0.0 \
        --n_samples 10 \
        --n_iter 1 \
        --scale 7.5 \
        --ddim_steps 50 \
        --plms \
        --skip_grid \
        --ckpt ./_model_pool/sd-v1-4-full-ema.ckpt \
        --from-file './name_of_your_coco_captions_file.txt' \
        --num_caption 10000 \ # to be adjusted
        --outdir ./path_of_your_targeted_images \
```
Additional details of text-to-image generation by Stable Diffusion can be found [HERE](https://github.com/CompVis/stable-diffusion#:~:text=active%20community%20development.-,Reference%20Sampling%20Script,-We%20provide%20a).

# Adversarial Attack & Black-box Query
![Teaser image](./assets/teaser_4.jpg)

# Evaluation
We use different types of CLIP text encoder (e.g., RN50, ViT-B/32, ViT-L/14, etc.) to evaluate the similarity between (a) the generated response and (b) the predefined targeted text $\boldsymbol{c}_\text{tar}$. Refer to the following eval script as an example:

```
CUDA_VISIBLE_DEVICES=0 \
python eval_clip_text_score.py \
--batch_size 250 \
--num_samples 10000 \
--pred_text_path ./_output_text/your_pred_captions.txt \
--tgt_text_path ./_output_text/your_tgt_captions.txt \
```

Alternatively, you can use [`wandb`](https://wandb.ai/site) to dynamically monitor the moving average of the CLIP score.

# Bibtex
If you find this project useful in your research, please consider citing our paper:

```
@article{zhao2023evaluate,
  title={On Evaluating Adversarial Robustness of Large Vision-Language Models},
  author={Zhao, Yunqing and Pang, Tianyu and Du, Chao and Yang, Xiao and Li, Chongxuan and Cheung, Ngai-Man and Lin, Min},
  journal={arXiv preprint arXiv:2305},
  year={2023}
}
```

# Acknowledgement: 

We appreciate the wonderful base implementation of [MiniGPT-4](https://github.com/Vision-CAIR/MiniGPT-4), [LLaVA](https://llava-vl.github.io/), [Unidiffuser](https://github.com/thu-ml/unidiffuser), [LAVIS](https://github.com/salesforce/LAVIS) and [CLIP](https://openai.com/research/clip). 

