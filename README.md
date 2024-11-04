# Mistral 7B Instruct

Download the model (~14GB):
```shell
wget https://models.mistralcdn.com/mistral-7b-v0-3/mistral-7B-Instruct-v0.3.tar
```

Build the snap and its component:
```shell
snapcraft -v
```

Install snap and then the component: 
```shell
sudo snap install --dangerous --devmode \
    mistral-7b-instruct_v0.3+0.0.0-alpha_amd64.snap \

sudo snap install --dangerous \
    mistral-7b-instruct+model-mistral-7b-instruct_v0.3.comp
```

Use:
```shell
mistral-7b-instruct.prompt mistral-7b-instruct
```