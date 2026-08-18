resource "kubernetes_storage_class" "gp2" {
  metadata {
    name = "gp2"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type   = "gp2"
    fsType = "ext4"
  }

  depends_on = [
    aws_eks_addon.ebs_csi_driver
  ]
}
