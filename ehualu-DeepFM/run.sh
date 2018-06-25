#!/bin/bash

#0 config
model_dir=/dockerdata/lambdaji/ml_packages/tf_repos/deep_ctr/model_ckpt/criteo/
data_dir=/dockerdata/lambdaji/ml_packages/data/criteo/

#1 feature pipline
python get_criteo_feature.py --input_dir=../../data/criteo/ --output_dir=../../data/criteo/ --cutoff=200

#2 model pipline
python wide_n_deep.py --model_type=wide --num_epochs=1 --batch_size=128 --deep_layers=256,128,64 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/lr/ --data_dir=${data_dir}
python wide_n_deep.py --model_type=wide_n_deep --num_epochs=1 --batch_size=128 --deep_layers=256,128,64 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/wide_n_deep/ --data_dir=${data_dir}
python DeepFM.py --learning_rate=0.0005 --optimizer=Adam --num_epochs=1 --batch_size=256 --field_size=39 --feature_size=117581 --deep_layers=400,400,400 --dropout=0.5,0.5,0.5 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/DeepFM/ --data_dir=${data_dir}
python PNN.py --model_type=FNN --learning_rate=0.05 --optimizer=Adagrad --num_epochs=1 --batch_size=128 --field_size=39 --feature_size=117581 --deep_layers=512 --dropout=0.5 --l2_reg=0.0005 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/FNN/ --data_dir=${data_dir}
python PNN.py --model_type=Inner --learning_rate=0.05 --optimizer=Adagrad --num_epochs=1 --batch_size=128 --field_size=39 --feature_size=117581 --deep_layers=512 --dropout=0.5 --l2_reg=0.0005 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/IPNN/ --data_dir=${data_dir}
#python PNN.py --model_type=Outer --learning_rate=0.005 --optimizer=Adam --num_epochs=1 --embedding_size=16 --batch_size=128 --field_size=39 --feature_size=117581 --deep_layers=300,100 --dropout=0.5,0.5 --l2_reg=0.1 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/OPNN/ --data_dir=${data_dir}
python NFM.py --learning_rate=0.00005 --optimizer=Adam --num_epochs=1 --batch_size=128 --embedding_size=256 --deep_layers=256,128 --dropout=0.5,0.5,0.5 --l2_reg=0.001 --field_size=39 --feature_size=117581 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/NFM/ --data_dir=${data_dir} --batch_norm=True
python AFM.py --learning_rate=0.0005 --optimizer=Adam --num_epochs=1 --batch_size=128 --embedding_size=256 --attention_layers=128 --dropout=0.5,0.5 --l2_reg=0.001 --field_size=39 --feature_size=117581 --log_steps=1000 --num_threads=8 --model_dir=${model_dir}/AFM/ --data_dir=${data_dir}

#3 serving pipline
python DeepFM.py --task_type=export --learning_rate=0.0005 --optimizer=Adam --batch_size=256 --field_size=39 --feature_size=117581 --deep_layers=400,400,400 --dropout=0.5,0.5,0.5 --log_steps=1000 --num_threads=8 --model_dir=./model_ckpt/criteo/DeepFM/ --servable_model_dir=./servable_model/
