#!/bin/bash
echo "running cloudinit.sh script"
echo "INSTALL"
sudo dnf install -y dnf-utils zip unzip gcc
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf remove -y runc

echo "INSTALL DOCKER"
sudo dnf install -y docker-ce --nobest

echo "ENABLE DOCKER"
sudo systemctl enable docker.service

echo "INSTALL NVIDIA CONT TOOLKIT"
sudo dnf install -y nvidia-container-toolkit

echo "START DOCKER"
sudo systemctl start docker.service
sudo usermod -a -G docker opc

echo "PYTHON packages"
python3 -m pip install --upgrade pip wheel oci
python3 -m pip install --upgrade setuptools
python3 -m pip install oci-cli
python3 -m pip install langchain
python3 -m pip install six

echo "GROWFS"
sudo /usr/libexec/oci-growfs -y

echo "Transaction monitoring"
echo "1. Install Python 3.9 and Git"
cd
sudo yum install python39 git wget unzip firewalld -y

echo "2. Upgrade pip"
python3.9 -m ensurepip --upgrade

echo "3. Set Python 3.9 as the default python3"
sudo alternatives --set python3 /usr/bin/python3.9
python3 --version

echo "4. Install Jupyter and other packages"
pip3 install --user jupyter numpy pandas matplotlib tqdm

echo "5. Install NVFlare"
python3 -m pip install --user nvflare

echo "6. Clone the NVFlare repository"
git clone https://github.com/NVIDIA/NVFlare.git
ls
pwd

echo "7. Switch to the 2.4 branch"
cd NVFlare && git switch 2.4

echo "8. Install Python packages for GNN example"
cd examples/advanced/gnn && pip3 install --user -r requirements.txt
export PATH=$PATH:/root/.local/bin

echo "9. Install additional PyG packages"
pip3 install --user pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.4.0+cpu.html

echo "10. Create the directory for the dataset"
mkdir -p /var/tmp/nvflare/datasets/elliptic_pp

echo "11. Download the dataset"
wget -O /var/tmp/nvflare/datasets/elliptic_pp/TransactionsDataset.zip https://objectstorage.us-ashburn-1.oraclecloud.com/n/ocisateam/b/EllipticPlusPlusDataset/o/TransactionsDataset.zip

echo "12. Unzip the dataset"
unzip -o /var/tmp/nvflare/datasets/elliptic_pp/TransactionsDataset.zip -d /var/tmp/nvflare/datasets/elliptic_pp

echo "13. Move the files to the correct location"
mv /var/tmp/nvflare/datasets/elliptic_pp/'Transactions Dataset'/* /var/tmp/nvflare/datasets/elliptic_pp
ls /var/tmp/nvflare/datasets/elliptic_pp

echo "14. Remove the now-empty directory"
rm -rf /var/tmp/nvflare/datasets/elliptic_pp/'Transactions Dataset'

echo "15. Configure NVFlare"
pwd
ls
nvflare config -jt ~/NVFlare/job_templates/

echo "16. Run the GraphSAGE finance script locally for each client"
python3 code/graphsage_finance_local.py --client_id 0
python3 code/graphsage_finance_local.py --client_id 1
python3 code/graphsage_finance_local.py --client_id 2

echo "17. Create an NVFlare job"
nvflare job create -force -j "/tmp/nvflare/jobs/gnn_finance" -w "sag_gnn" -sd "code" -f app_1/config_fed_client.conf app_script="graphsage_finance_fl.py" app_config="--client_id 1 --epochs 10" -f app_2/config_fed_client.conf app_script="graphsage_finance_fl.py" app_config="--client_id 2 --epochs 10" -f app_server/config_fed_server.conf num_rounds=7 key_metric="validation_auc" model_class_path="pyg_sage.SAGE" components[0].args.model.args.in_channels=165 components[0].args.model.args.hidden_channels=256 components[0].args.model.args.num_layers=3 components[0].args.model.args.num_classes=2

echo "18. Run NVFlare simulator"
nvflare simulator -w /tmp/nvflare/gnn/finance_fl_workspace -n 2 -t 2 /tmp/nvflare/jobs/gnn_finance

echo "19. Open firewall for TensorBoard"
echo "FIREWALL"
sudo systemctl stop firewalld
sudo firewall-offline-cmd --zone=public --add-port=6006/tcp
sudo systemctl start firewalld

echo "20. Start TensorBoard"
tensorboard --logdir /tmp/nvflare/gnn --host 0.0.0.0 --port 6006 &

echo "21. Install and start Jupyter"

docker run -d \
    -p 8888:8888 \
    --restart always \
    --name myjupyter \
    -e JUPYTER_ENABLE_LAB=yes \
    -e JUPYTER_TOKEN="" \
    -e JUPYTER_PASSWORD="" \
    -v "$PWD/notebooks":/home/jovyan/work \
    -v /tmp/nvflare/gnn:/tmp/nvflare/gnn \
    --user root \
    --dns 8.8.8.8 \
    jupyter/base-notebook bash -c "apt-get update && apt-get install -y git && git clone https://github.com/adinadiana1234/transactionmonitoring_notebooks.git /home/jovyan/work/repo && mv /home/jovyan/work/repo/* /home/jovyan/ && rm -rf /home/jovyan/work/repo && start-notebook.sh --NotebookApp.token='' --NotebookApp.password='' --allow-root --ip=0.0.0.0 --port=8888 --no-browser"



echo "22. Open firewall for Jupyter"
echo "FIREWALL"
sudo systemctl stop firewalld
sudo firewall-offline-cmd --zone=public --add-port=8888/tcp
sudo systemctl start firewalld